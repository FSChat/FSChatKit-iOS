//
//  FSConstants.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//


import Foundation

struct FSConstants {

    struct Thread {
        static let content = "content"
        static let senderId = "sender_id"
        static let timestamp = "timestamp"
    }

    struct Collections {

        struct Chat {
            static let sernders = "senders"
            static let threads = "threads"

        }
        struct ChatRooms {

            static let oppositeUserId = "opposite_user_id"
            static let oppositeUser = "opposite_user"

        }

        static let users = "users"
        static let chat = "chat"

        struct Users {
            static let serverId = "server_id"
            static let name = "name"
            static let fcmToken = "fcm_token"
            static let chatRoomsSubCollection = "chat_rooms"
            static let chatRooms = ChatRooms()
        }

    }
}
