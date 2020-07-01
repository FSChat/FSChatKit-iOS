//
//  OneToOneRoom.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation
import Firebase

struct OneToOneRoom: Comparable {
    
    let id: String
    var oppositeUser: OppositeUser!
    var oppositeUserId: String!
    var seen: Bool?
    var message: LastMessage?
}

extension OneToOneRoom {
    
    init?(document: DocumentSnapshot) {
        
        guard let data = document.data() else { return nil }
        
        guard let oppositeUserId = data["opposite_user_id"] as? String else {
            return nil
        }
        
        guard let oppositeUserData = data["opposite_user"] as? [String: Any] ,
            let oppositeUser = OppositeUser(fromDictionary: oppositeUserData) else {
                return nil
        }
        
        let isSeen = data["seen"] as? Bool ?? true
        
        if let lastMessage = data["last_message"] as? [String: Any] {
            let message = LastMessage(fromDictionary: lastMessage)
            self.message = message
        }
        id = document.documentID
        self.oppositeUserId = oppositeUserId
        self.oppositeUser = oppositeUser
        self.seen = isSeen
    }
    
    func toDictionary() -> [String: Any] {
        
        var dictionary = [String: Any]()
        if oppositeUser != nil {
            dictionary["opposite_user"] = oppositeUser.toDictionary()
        }
        if oppositeUserId != nil {
            dictionary["opposite_user_id"] = oppositeUserId
        }
        
        dictionary["opposite_user"] = true
        return dictionary
    }
    
}
extension OneToOneRoom {
    static func == (lhs: OneToOneRoom, rhs: OneToOneRoom) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: OneToOneRoom, rhs: OneToOneRoom) -> Bool {
        return lhs.id < rhs.id
    }
}
