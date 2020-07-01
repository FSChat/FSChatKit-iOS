//
//  FSUser.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation
import Firebase

struct FSUser {
    
    /*
     {
     "name": "",
     "server_id" : "",
     "fcm_token" : ""
     }
     */
    let uid: String
    var fcmToken: String?
    var name: String
    let serverId: String?
    var badge: Int = 0
    var lang: String? = "en"
    
    var senderId: String {
        return uid
    }
    
    var displayName: String {
        return name
    }
    
    init(uid: String, name: String, serverId: String? , currentLanguage: String?) {
        self.uid = uid
        self.fcmToken = nil
        self.name = name
        self.serverId = serverId
        self.lang = currentLanguage
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case fcmToken = "fcm_token"
        case name = "name"
        case serverId = "server_id"
        case badge = "badge"
        case lang = "lang"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uid = try values.decode(String.self, forKey: .uid)
        fcmToken = try values.decodeIfPresent(String.self, forKey: .fcmToken)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        serverId = try values.decodeIfPresent(String.self, forKey: .serverId)
        badge = try values.decodeIfPresent(Int.self, forKey: .badge) ?? 0
        lang = try values.decodeIfPresent(String.self, forKey: .lang) ?? "ar"
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        uid = document.documentID
        self.name = name
        self.serverId = data["server_id"] as? String
        self.fcmToken = data["fcm_token"] as? String
        self.lang = data["lang"] as? String ?? "ar"
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            return nil
        }
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        uid = document.documentID
        self.name = name
        self.serverId = data["server_id"] as? String
        self.fcmToken = data["fcm_token"] as? String
        self.lang = data["lang"] as? String ?? "ar"
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if fcmToken != nil {
            dictionary["fcm_token"] = fcmToken
        }
           
        
        if serverId != nil {
            dictionary["server_id"] = serverId
        }
        
        if lang != nil {
            dictionary["lang"] = lang
        }
        dictionary["uid"] = uid
        dictionary["name"] = name
        dictionary["platform"] = "iOS"
        dictionary["last_update"] = FieldValue.serverTimestamp()
        return dictionary
    }
    
}

extension FSUser {
    
    static func chatRoomForOppositeUser(oppositeId: String, oppositeName: String? ) -> [String: Any] {
        
        return [ "opposite_user_id": oppositeId,
                 "seen": false,
                 "opposite_user": [
                    "id": oppositeId,
                    "name": oppositeName ?? "" ]
        ]
    }
}
