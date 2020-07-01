//
//  UIColor+chat.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//


import Firebase


struct Channel {

    let id: String
    let senders: [String]

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let chatUsers = data["senders"] as? [String] else {
            return nil
        }

        id = document.documentID
        senders = chatUsers
    }

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }

        guard let chatUsers = data["senders"] as? [String] else {
            return nil
        }

        id = document.documentID
        senders = chatUsers
    }

}

extension Channel: DatabaseRepresentation {

    var representation: [String: Any] {
        let rep: [String: Any] = [
            "id": id,
            "senders": senders
        ]
        return rep
    }

}

extension Channel: Comparable {

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id < rhs.id
    }

}
