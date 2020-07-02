//
//  ExternalAPIs.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation

typealias FSCKStatusCode = Int

public protocol ExternalAPIs {
    
    public func setChatUser(
         firebaseID: String,
         completion: @escaping (
         _ result: Swift.Result<Bool, Error>,
         _ statusCode: FSCKStatusCode?) -> Void)
    
    public func getChatUser(
          userID: String,
          completion: @escaping (
          _ result: Swift.Result<Bool, Error>,
          _ statusCode: FSCKStatusCode?) -> Void)
}
