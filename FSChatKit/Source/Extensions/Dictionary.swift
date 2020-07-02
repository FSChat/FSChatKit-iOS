//
//  Dictionary.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation
import Firebase

extension Dictionary where Key == String, Value == Any {
    
    func timestampDecorated() -> Dictionary {
        var dic = self
        dic["last_update"] = FieldValue.serverTimestamp()
        return dic
    }
}
