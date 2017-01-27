////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import XCTest
import RealmSwift

#if swift(>=3.0)
class SwiftObjectServerTests: SwiftSyncTestCase {
    /// It should be possible to successfully open a Realm configured for sync.
    func testBasicSwiftSync() {
        let url = URL(string: "realm://localhost:9080/~/testBasicSync")!
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: true), server: authURL)
            let realm = try synchronouslyOpenRealm(url: url, user: user)
            XCTAssert(realm.isEmpty, "Freshly synced Realm was not empty...")
        } catch {
            XCTFail("Got an error: \(error)")
        }
    }

    /// If client B adds objects to a Realm, client A should see those new objects.
    func testSwiftAddObjects() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            if isParent {
                waitForDownloads(for: user, url: realmURL)
                checkCount(expected: 0, realm, SwiftSyncObject.self)
                executeChild()
                waitForDownloads(for: user, url: realmURL)
                checkCount(expected: 3, realm, SwiftSyncObject.self)
            } else {
                // Add objects
                try realm.write {
                    realm.add(SwiftSyncObject(value: ["child-1"]))
                    realm.add(SwiftSyncObject(value: ["child-2"]))
                    realm.add(SwiftSyncObject(value: ["child-3"]))
                }
                waitForUploads(for: user, url: realmURL)
                checkCount(expected: 3, realm, SwiftSyncObject.self)
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    /// If client B removes objects from a Realm, client A should see those changes.
    func testSwiftDeleteObjects() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            if isParent {
                try realm.write {
                    realm.add(SwiftSyncObject(value: ["child-1"]))
                    realm.add(SwiftSyncObject(value: ["child-2"]))
                    realm.add(SwiftSyncObject(value: ["child-3"]))
                }
                waitForUploads(for: user, url: realmURL)
                checkCount(expected: 3, realm, SwiftSyncObject.self)
                executeChild()
                waitForDownloads(for: user, url: realmURL)
                checkCount(expected: 0, realm, SwiftSyncObject.self)
            } else {
                try realm.write {
                    realm.deleteAll()
                }
                waitForUploads(for: user, url: realmURL)
                checkCount(expected:0, realm, SwiftSyncObject.self)
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    // MARK: Client reset

    func testClientReset() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)

            var theError: SyncError?
            let ex = expectation(description: "Waiting for error handler to be called...")
            SyncManager.shared.errorHandler = { (error, session) in
                if let error = error as? SyncError {
                    theError = error
                } else {
                    XCTFail("Error \(error) was not a sync error. Something is wrong.")
                }
                ex.fulfill()
            }
            user.simulateClientResetError(forSession: realmURL)
            waitForExpectations(timeout: 10, handler: nil)
            XCTAssertNotNil(theError)
            XCTAssertTrue(theError!.code == SyncError.Code.clientResetError)
            let resetInfo = theError!.clientResetInfo()
            XCTAssertNotNil(resetInfo)
            XCTAssertTrue(resetInfo!.0.contains("io.realm.object-server-recovered-realms/recovered_realm"))
            XCTAssertNotNil(realm)
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    func testClientResetManualInitiation() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            var theError: SyncError?

            try autoreleasepool { _ in
                let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
                let ex = expectation(description: "Waiting for error handler to be called...")
                SyncManager.shared.errorHandler = { (error, session) in
                    if let error = error as? SyncError {
                        theError = error
                    } else {
                        XCTFail("Error \(error) was not a sync error. Something is wrong.")
                    }
                    ex.fulfill()
                }
                user.simulateClientResetError(forSession: realmURL)
                waitForExpectations(timeout: 10, handler: nil)
                XCTAssertNotNil(theError)
                XCTAssertNotNil(realm)
            }
            let (path, closure) = theError!.clientResetInfo()!
            XCTAssertFalse(FileManager.default.fileExists(atPath: path))
            closure()
            XCTAssertTrue(FileManager.default.fileExists(atPath: path))
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    // MARK: Progress notifiers

    func testStreamingDownloadNotifier() {
        let bigObjectCount = 2
        do {
            var callCount = 0
            var transferred = 0
            var transferrable = 0
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            if isParent {
                let session = user.session(for: realmURL)
                XCTAssertNotNil(session)
                let token = session!.addProgressNotification(for: .download, mode: .reportIndefinitely) { p in
                    callCount += 1
                    XCTAssert(p.transferredBytes >= transferred)
                    XCTAssert(p.transferrableBytes >= transferrable)
                    transferred = p.transferredBytes
                    transferrable = p.transferrableBytes
                }
                // Wait for the child process to upload all the data.
                executeChild()
                waitForDownloads(for: user, url: realmURL)
                token!.stop()
                XCTAssert(callCount > 1)
                XCTAssert(transferred >= transferrable)
            } else {
                try realm.write {
                    for _ in 0..<bigObjectCount {
                        realm.add(SwiftHugeSyncObject())
                    }
                }
                waitForUploads(for: user, url: realmURL)
                checkCount(expected:bigObjectCount, realm, SwiftHugeSyncObject.self)
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    func testStreamingUploadNotifier() {
        let bigObjectCount = 2
        do {
            var callCount = 0
            var transferred = 0
            var transferrable = 0
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            let session = user.session(for: realmURL)
            XCTAssertNotNil(session)
            let token = session!.addProgressNotification(for: .upload, mode: .reportIndefinitely) { p in
                callCount += 1
                XCTAssert(p.transferredBytes >= transferred)
                XCTAssert(p.transferrableBytes >= transferrable)
                transferred = p.transferredBytes
                transferrable = p.transferrableBytes
            }
            try realm.write {
                for _ in 0..<bigObjectCount {
                    realm.add(SwiftHugeSyncObject())
                }
            }
            waitForUploads(for: user, url: realmURL)
            token!.stop()
            XCTAssert(callCount > 1)
            XCTAssertEqual(transferred, transferrable)
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    // MARK: Permissions

    func testPermissionChange() {
        do {
            let userA = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_A"), server: authURL)
            let userB = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_B"), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: userA)

            let adminPermissions = [
                [true, true, true],
                [false, true, true],
                [true, false, true],
                [false, false, true]
            ]
            let readWritePermissions = [[true, true, false]]
            let readOnlyPermissions = [[true, false, false]]
            let noAccessPermissions: [[Bool?]] = [
                [false, false, false],
                [nil, nil, nil]
            ]
            let permissions = [adminPermissions, readWritePermissions, readOnlyPermissions, noAccessPermissions]
            let statusMessages = [
                "administrative access",
                "read-write access",
                "read-only access",
                "no access"
            ]

            for (accessPermissions, statusMessage) in zip(permissions, statusMessages) {
                for permissions in accessPermissions {
                    let permissionChange = SyncPermissionChange(
                        realmURL: realmURL.absoluteString,
                        userID: userB.identity!,
                        mayRead: permissions[0],
                        mayWrite: permissions[1],
                        mayManage: permissions[2]
                    )
                    try verifyChangePermission(change: permissionChange, statusMessage: statusMessage, owner: userA)
                }
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    func verifyChangePermission(change: SyncPermissionChange, statusMessage: String, owner: SyncUser) throws {
        let managementRealm = try owner.managementRealm()

        let exp = expectation(description: "A new permission will be granted by the server")
        let token = managementRealm.objects(SyncPermissionChange.self).filter("id = %@", change.id).addNotificationBlock { changes in
            if case .update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                XCTAssertEqual(statusCode, 0)
                XCTAssertEqual(change[0].status, .success)
                XCTAssertNotNil(change[0].statusMessage?.range(of: statusMessage))
                exp.fulfill()
            }
        }

        try managementRealm.write {
            managementRealm.add(change)
        }

        waitForExpectations(timeout: 2)
        token.stop()
    }

    func testPermissionOffer() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: user)

            let managementRealm = try user.managementRealm()
            let permissionOffer = SyncPermissionOffer(realmURL: realmURL.absoluteString, expiresAt: Date(timeIntervalSinceNow: 30 * 24 * 60 * 60), mayRead: true, mayWrite: true, mayManage: false)

            let exp = expectation(description: "A new permission offer will be processed by the server")

            let results = managementRealm.objects(SyncPermissionOffer.self).filter("id = %@", permissionOffer.id)
            let notificationToken = results.addNotificationBlock { (changes) in
                if case .update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                    XCTAssertEqual(statusCode, 0)
                    XCTAssertEqual(change[0].status, .success)
                    exp.fulfill()
                }
            }

            try managementRealm.write {
                managementRealm.add(permissionOffer)
            }

            waitForExpectations(timeout: 2)
            notificationToken.stop()
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    func testPermissionOfferResponse() {
        do {
            let userA = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_A"), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: userA)

            var managementRealm = try userA.managementRealm()
            let permissionOffer = SyncPermissionOffer(realmURL: realmURL.absoluteString, expiresAt: Date(timeIntervalSinceNow: 30 * 24 * 60 * 60), mayRead: true, mayWrite: true, mayManage: false)

            var permissionToken: String?

            var exp = expectation(description: "A new permission offer will be processed by the server")

            let permissionOfferNotificationToken = managementRealm
                .objects(SyncPermissionOffer.self)
                .filter("id = %@", permissionOffer.id)
                .addNotificationBlock { (changes) in
                if case .update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                    XCTAssertEqual(statusCode, 0)
                    XCTAssertEqual(change[0].status, .success)

                    permissionToken = change[0].token
                    exp.fulfill()
                }
            }

            try managementRealm.write {
                managementRealm.add(permissionOffer)
            }

            waitForExpectations(timeout: 2)
            permissionOfferNotificationToken.stop()

            let userB = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_B"), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: userB)

            managementRealm = try userB.managementRealm()

            XCTAssertNotNil(permissionToken)

            var responseRealmUrl: String?
            let permissionOfferResponse = SyncPermissionOfferResponse(token: permissionToken!)

            exp = expectation(description: "A new permission offer response will be processed by the server")

            let permissionOfferResponseNotificationToken = managementRealm
                .objects(SyncPermissionOfferResponse.self)
                .filter("id = %@", permissionOfferResponse.id)
                .addNotificationBlock { (changes) in
                if case .update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                    XCTAssertEqual(statusCode, 0)
                    XCTAssertEqual(change[0].status, .success)
                    XCTAssertEqual(change[0].realmUrl, String(format: "realm://localhost:9080/%@/testBasicSync", userA.identity!))

                    responseRealmUrl = change[0].realmUrl

                    exp.fulfill()
                }
            }

            try managementRealm.write {
                managementRealm.add(permissionOfferResponse)
            }

            waitForExpectations(timeout: 2)
            permissionOfferResponseNotificationToken.stop()

            _ = try synchronouslyOpenRealm(url: URL(string: responseRealmUrl!)!, user: userB)
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }
}
#else
class SwiftObjectServerTests: SwiftSyncTestCase {
    /// It should be possible to successfully open a Realm configured for sync.
    func testBasicSwiftSync() {
        let url = NSURL(string: "realm://localhost:9080/~/testBasicSync")!
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: true), server: authURL)
            let realm = try synchronouslyOpenRealm(url: url, user: user)
            XCTAssert(realm.isEmpty, "Freshly synced Realm was not empty...")
        } catch {
            XCTFail("Got an error: \(error)")
        }
    }

    /// If client B adds objects to a Realm, client A should see those new objects.
    func testSwiftAddObjects() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            if isParent {
                waitForDownloadsForUser(user, url: realmURL)
                checkCount(expected: 0, realm, SwiftSyncObject.self)
                executeChild()
                waitForDownloadsForUser(user, url: realmURL)
                checkCount(expected: 3, realm, SwiftSyncObject.self)
            } else {
                // Add objects
                try realm.write {
                    realm.add(SwiftSyncObject(value: ["child-1"]))
                    realm.add(SwiftSyncObject(value: ["child-2"]))
                    realm.add(SwiftSyncObject(value: ["child-3"]))
                }
                waitForUploadsForUser(user, url: realmURL)
                checkCount(expected: 3, realm, SwiftSyncObject.self)
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    /// If client B removes objects from a Realm, client A should see those changes.
    func testSwiftDeleteObjects() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            if isParent {
                try realm.write {
                    realm.add(SwiftSyncObject(value: ["child-1"]))
                    realm.add(SwiftSyncObject(value: ["child-2"]))
                    realm.add(SwiftSyncObject(value: ["child-3"]))
                }
                waitForUploadsForUser(user, url: realmURL)
                checkCount(expected: 3, realm, SwiftSyncObject.self)
                executeChild()
                waitForDownloadsForUser(user, url: realmURL)
                checkCount(expected: 0, realm, SwiftSyncObject.self)
            } else {
                try realm.write {
                    realm.deleteAll()
                }
                waitForUploadsForUser(user, url: realmURL)
                checkCount(expected:0, realm, SwiftSyncObject.self)
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    // MARK: Progress notifiers

    func testStreamingDownloadNotifier() {
        let bigObjectCount = 2
        do {
            var callCount = 0
            var transferred = 0
            var transferrable = 0
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            if isParent {
                let session = user.sessionForURL(realmURL)
                XCTAssertNotNil(session)
                let token = session!.addProgressNotificationForDirection(.Download, mode: .ReportIndefinitely) { p in
                    callCount += 1
                    XCTAssert(p.transferredBytes >= transferred)
                    XCTAssert(p.transferrableBytes >= transferrable)
                    transferred = p.transferredBytes
                    transferrable = p.transferrableBytes
                }
                // Wait for the child process to upload all the data.
                executeChild()
                waitForDownloadsForUser(user, url: realmURL)
                token!.stop()
                XCTAssert(callCount > 1)
                XCTAssert(transferred >= transferrable)
            } else {
                try realm.write {
                    for _ in 0..<bigObjectCount {
                        realm.add(SwiftHugeSyncObject())
                    }
                }
                waitForUploadsForUser(user, url: realmURL)
                checkCount(expected:bigObjectCount, realm, SwiftHugeSyncObject.self)
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    func testStreamingUploadNotifier() {
        let bigObjectCount = 2
        do {
            var callCount = 0
            var transferred = 0
            var transferrable = 0
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            let realm = try synchronouslyOpenRealm(url: realmURL, user: user)
            let session = user.sessionForURL(realmURL)
            XCTAssertNotNil(session)
            let token = session!.addProgressNotificationForDirection(.Upload, mode: .ReportIndefinitely) { p in
                callCount += 1
                XCTAssert(p.transferredBytes >= transferred)
                XCTAssert(p.transferrableBytes >= transferrable)
                transferred = p.transferredBytes
                transferrable = p.transferrableBytes
            }
            try realm.write {
                for _ in 0..<bigObjectCount {
                    realm.add(SwiftHugeSyncObject())
                }
            }
            waitForUploadsForUser(user, url: realmURL)
            token!.stop()
            XCTAssert(callCount > 1)
            XCTAssert(transferred >= transferrable)
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    // MARK: Permissions

    func testPermissionChange() {
        do {
            let userA = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_A"), server: authURL)
            let userB = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_B"), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: userA)

            let adminPermissions: [[Bool?]] = [
                [true, true, true],
                [false, true, true],
                [true, false, true],
                [false, false, true]
            ]
            let readWritePermissions: [[Bool?]] = [[true, true, false]]
            let readOnlyPermissions: [[Bool?]] = [[true, false, false]]
            let noAccessPermissions: [[Bool?]] = [
                [false, false, false],
                [nil, nil, nil]
            ]
            let permissions: [[[Bool?]]] = [adminPermissions, readWritePermissions, readOnlyPermissions, noAccessPermissions]
            let statusMessages = [
                "administrative access",
                "read-write access",
                "read-only access",
                "no access"
            ]

            for (accessPermissions, statusMessage) in zip(permissions, statusMessages) {
                for permissions in accessPermissions {
                    let permissionChange = SyncPermissionChange(
                        realmURL: realmURL.absoluteString!,
                        userID: userB.identity!,
                        mayRead: permissions[0],
                        mayWrite: permissions[1],
                        mayManage: permissions[2]
                    )
                    try verifyChangePermission(change: permissionChange, statusMessage: statusMessage, owner: userA)
                }
            }
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    func verifyChangePermission(change change: SyncPermissionChange, statusMessage: String, owner: SyncUser) throws {
        let managementRealm = try owner.managementRealm()

        let exp = expectationWithDescription("A new permission will be granted by the server")
        let token = managementRealm.objects(SyncPermissionChange.self).filter("id = %@", change.id).addNotificationBlock { changes in
            if case .Update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                XCTAssertEqual(statusCode, 0)
                XCTAssertEqual(change[0].status, SyncManagementObjectStatus.Success)
                XCTAssertNotNil(change[0].statusMessage?.rangeOfString(statusMessage))
                exp.fulfill()
            }
        }

        try managementRealm.write {
            managementRealm.add(change)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
        token.stop()
    }

    func testPermissionOffer() {
        do {
            let user = try synchronouslyLogInUser(for: basicCredentials(register: isParent), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: user)

            let managementRealm = try user.managementRealm()
            let permissionOffer = SyncPermissionOffer(realmURL: realmURL.absoluteString!, expiresAt: NSDate(timeIntervalSinceNow: 30 * 24 * 60 * 60), mayRead: true, mayWrite: true, mayManage: false)

            let exp = expectationWithDescription("A new permission offer will be processed by the server")

            let results = managementRealm.objects(SyncPermissionOffer.self).filter("id = %@", permissionOffer.id)
            let notificationToken = results.addNotificationBlock { (changes) in
                if case .Update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                    XCTAssertEqual(statusCode, 0)
                    XCTAssertEqual(change[0].status, SyncManagementObjectStatus.Success)
                    exp.fulfill()
                }
            }

            try managementRealm.write {
                managementRealm.add(permissionOffer)
            }

            waitForExpectationsWithTimeout(2, handler: nil)
            notificationToken.stop()
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }

    func testPermissionOfferResponse() {
        do {
            let userA = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_A"), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: userA)

            var managementRealm = try userA.managementRealm()
            let permissionOffer = SyncPermissionOffer(realmURL: realmURL.absoluteString!, expiresAt: NSDate(timeIntervalSinceNow: 30 * 24 * 60 * 60), mayRead: true, mayWrite: true, mayManage: false)

            var permissionToken: String?

            var exp = expectationWithDescription("A new permission offer will be processed by the server")

            let permissionOfferNotificationToken = managementRealm
                .objects(SyncPermissionOffer.self)
                .filter("id = %@", permissionOffer.id)
                .addNotificationBlock { (changes) in
                    if case .Update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                        XCTAssertEqual(statusCode, 0)
                        XCTAssertEqual(change[0].status, SyncManagementObjectStatus.Success)

                        permissionToken = change[0].token
                        exp.fulfill()
                    }
            }

            try managementRealm.write {
                managementRealm.add(permissionOffer)
            }

            waitForExpectationsWithTimeout(2, handler: nil)
            permissionOfferNotificationToken.stop()

            let userB = try synchronouslyLogInUser(for: basicCredentials(register: isParent, usernameSuffix: "_B"), server: authURL)
            _ = try synchronouslyOpenRealm(url: realmURL, user: userB)

            managementRealm = try userB.managementRealm()

            XCTAssertNotNil(permissionToken)

            var responseRealmUrl: String?
            let permissionOfferResponse = SyncPermissionOfferResponse(token: permissionToken!)

            exp = expectationWithDescription("A new permission offer response will be processed by the server")

            let permissionOfferResponseNotificationToken = managementRealm
                .objects(SyncPermissionOfferResponse.self)
                .filter("id = %@", permissionOfferResponse.id)
                .addNotificationBlock { (changes) in
                    if case .Update(let change, _, _, _) = changes, let statusCode = change[0].statusCode.value {
                        XCTAssertEqual(statusCode, 0)
                        XCTAssertEqual(change[0].status, SyncManagementObjectStatus.Success)
                        XCTAssertEqual(change[0].realmUrl, String(format: "realm://localhost:9080/%@/testBasicSync", userA.identity!))

                        responseRealmUrl = change[0].realmUrl

                        exp.fulfill()
                    }
            }

            try managementRealm.write {
                managementRealm.add(permissionOfferResponse)
            }

            waitForExpectationsWithTimeout(2, handler: nil)
            permissionOfferResponseNotificationToken.stop()

            _ = try synchronouslyOpenRealm(url: NSURL(string: responseRealmUrl!)!, user: userB)
        } catch {
            XCTFail("Got an error: \(error) (process: \(isParent ? "parent" : "child"))")
        }
    }
}
#endif
