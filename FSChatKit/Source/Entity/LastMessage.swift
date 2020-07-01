//
//  LastMessage.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation
import Firebase

struct LastMessage {
    
    var content: String!
    var timestamp: Date!
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String: Any]) {
        content = dictionary["content"] as? String
        timestamp = (dictionary["timestamp"] as? Firebase.Timestamp)?.dateValue()
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if content != nil {
            dictionary["content"] = content
        }
        if timestamp != nil {
            dictionary["timestamp"] = timestamp
        }
        return dictionary
    }
    
}
