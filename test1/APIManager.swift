//
//  APIManager.swift
//  test1
//
//  Created by ShuichiNagao on 8/15/16.
//  Copyright © 2016 ShuichiNagao. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import BrightFutures

class APIManager: NSObject {
    
    static let sharedInstance = APIManager()
    
    func get<T: ResponseSerializerType>(url: URLStringConvertible, params: [String: AnyObject], serializer: T) -> Future<T.SerializedObject, T.ErrorObject> {
        let promise = Promise<T.SerializedObject, T.ErrorObject>()
        
        Alamofire.request(.GET, url, parameters: params)
            .validate()
            .response(responseSerializer: serializer) { response in
                switch response.result {
                case .Success(let r):
                    promise.success(r)
                    
                case .Failure(let error):
                    print(error)
                    promise.failure(error)
                }
        }
        return promise.future
    }
    
}