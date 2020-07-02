//
//  AppUserProfile.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation

public protocol AppUserProfile {
    var userId: String { get }
    var name: String { get }
    var email: String { get }
    var language:String? { get }
    var fcmToken:String? { get }
}



public protocol RoomUser {
    var uid: String { get }
    var name: String { get }
}
