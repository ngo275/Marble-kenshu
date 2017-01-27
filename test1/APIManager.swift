//
//  APIManager.swift
//  test1
//
//  Created by ShuichiNagao on 8/15/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import Foundation
import SwiftyJSON
import APIKit
import BrightFutures

struct APIManager {
    
    static func send<T: MarbleRequest>(request: T, callbackQueue queue: CallbackQueue? = nil) -> Future<T.Response, SessionTaskError> {
        
        let promise = Promise<T.Response, SessionTaskError>()
        
        Session.send(request, callbackQueue: queue) { result in
            switch result {
            case let .success(data):
                promise.success(data)
                
            case let .failure(error):
                promise.failure(error)
            }
        }
        
        return promise.future
    }
    
}
