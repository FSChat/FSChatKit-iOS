//
//  ExternalAPIs.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation

public typealias FSCKStatusCode = Int

public protocol ExternalAPIs {
    
    func setChatUser(
         firebaseID: String,
         completion: @escaping (
         _ result: Swift.Result<Bool, Error>,
         _ statusCode: FSCKStatusCode?) -> Void)
    
    func getChatUser(
          userID: String,
          completion: @escaping (
          _ result: Swift.Result<Bool, Error>,
          _ statusCode: FSCKStatusCode?) -> Void)
}
