//
//  OppositeUser.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation

struct OppositeUser {

    var id: String!
    var name: String!

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init?(fromDictionary dictionary: [String: Any]) {

        guard let id = dictionary["id"] as? String else {
            return nil
        }

        guard let name = dictionary["name"] as? String else {
            return nil
        }
        self.id = id
        self.name = name
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if id != nil {
            dictionary["id"] = id
        }
        if name != nil {
            dictionary["name"] = name
        }
        return dictionary
    }

}
