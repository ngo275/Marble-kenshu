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

#import "RLMMultiProcessTestCase.h"

typedef void(^RLMSyncBasicErrorReportingBlock)(NSError * _Nullable);

NS_ASSUME_NONNULL_BEGIN

@interface RLMSyncManager ()
- (void)setSessionCompletionNotifier:(RLMSyncBasicErrorReportingBlock)sessionCompletionNotifier;
@end

@interface SyncObject : RLMObject
@property NSString *stringProp;
@end

@interface HugeSyncObject : RLMObject
@property NSData *dataProp;
+ (instancetype)object;
@end

@interface RLMSyncTestCase : RLMMultiProcessTestCase

+ (RLMSyncManager *)managerForCurrentTest;

+ (NSURL *)rootRealmCocoaURL;

+ (NSURL *)authServerURL;

+ (RLMSyncCredentials *)basicCredentialsWithName:(NSString *)name register:(BOOL)shouldRegister;

/// Synchronously open a synced Realm and wait until the binding process has completed or failed.
- (RLMRealm *)openRealmForURL:(NSURL *)url user:(RLMSyncUser *)user;

/// Immediately open a synced Realm.
- (RLMRealm *)immediatelyOpenRealmForURL:(NSURL *)url user:(RLMSyncUser *)user;

/// Synchronously create, log in, and return a user.
- (RLMSyncUser *)logInUserForCredentials:(RLMSyncCredentials *)credentials
                                  server:(NSURL *)url;

/// Add a number of objects to a Realm.
- (void)addSyncObjectsToRealm:(RLMRealm *)realm descriptions:(NSArray<NSString *> *)descriptions;

/// Synchronously wait for downloads to complete for any number of Realms, and then check their `SyncObject` counts.
- (void)waitForDownloadsForUser:(RLMSyncUser *)user
                         realms:(NSArray<RLMRealm *> *)realms
                      realmURLs:(NSArray<NSURL *> *)realmURLs
                 expectedCounts:(NSArray<NSNumber *> *)counts;

/// "Prime" the sync manager to signal the given semaphore the next time a session is bound. This method should be
/// called right before a Realm is opened if that Realm's session is the one to be monitored.
- (void)primeSyncManagerWithSemaphore:(nullable dispatch_semaphore_t)semaphore;

/// Waits for downloads to complete while spinning the runloop. This method uses expectations.
- (void)waitForDownloadsForUser:(RLMSyncUser *)user url:(NSURL *)url;

/// Waits for uploads to complete while spinning the runloop. This method uses expectations.
- (void)waitForUploadsForUser:(RLMSyncUser *)user url:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

#define WAIT_FOR_SEMAPHORE(macro_semaphore, macro_timeout) \
{                                                                                                                      \
    int64_t delay_in_ns = (int64_t)(macro_timeout * NSEC_PER_SEC);                                                     \
    BOOL sema_success = dispatch_semaphore_wait(macro_semaphore, dispatch_time(DISPATCH_TIME_NOW, delay_in_ns)) == 0;  \
    XCTAssertTrue(sema_success, @"Semaphore timed out.");                                                              \
}

#define CHECK_COUNT(d_count, macro_object_type, macro_realm) \
{                                                                                                       \
    NSInteger c = [macro_object_type allObjectsInRealm:macro_realm].count;                              \
    NSString *w = self.isParent ? @"parent" : @"child";                                                 \
    XCTAssert(d_count == c, @"Expected %@ items, but actually got %@ (%@)", @(d_count), @(c), w);       \
}
