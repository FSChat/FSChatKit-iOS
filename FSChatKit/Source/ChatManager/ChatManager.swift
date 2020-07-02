//
//  UIColor+chat.swift
//  FSChatKit
//
//  Created by Bassem Abbas on 7/1/20.
//  Copyright © 2020 Bassem Abbas. All rights reserved.
//

import Foundation
import Firebase

public class ChatManager {
    
    public static var emailPrefix = ""
    
    public static let manager = ChatManager()
    
    public static let db = Firestore.firestore()
    
    public var externalApis : ExternalAPIs?
    
    private var userId:String?
 
    private var db: Firestore {
        ChatManager.db
    }
    
    private(set) var myUser: FSUser! {
        didSet {
            userDidUpdate()
        }
    }
    
    private var channelsReference: CollectionReference {
        return db.collection(FSConstants.Collections.chat)
    }

    private var myUserRefrance: DocumentReference {
        return db.collection(
            [FSConstants.Collections.users
                ].joined(separator: "/")
        ).document(myUser.uid)
    }
    

    
    public static func updateUserOnServerWithFirebaseId(fid: String) {
        //TODO:
        
        manager.externalApis?.setChatUser(
        firebaseID: fid) { (result, status) in
            print(status as Any, result)
        }
        
    }
    
    static func reportFirebaseRegisterError(error: Error?) {
          print(error)
          // show to user a mesage
          //   crashlytics().record(error: error)
          
      }
    
    public static func login(appUser: AppUserProfile, password: String) {
       loginUserToFirebase(user: appUser, type: emailPrefix, password: password)
    }
    
    private static func loginUserToFirebase(user: AppUserProfile, type: String , password: String) {
        let email = user.email
        let prefix = type.count > 0 ? "\(type)_" : ""
        let prefixedEmail = "\(prefix)\(email)"
        Auth.auth().signIn(withEmail: prefixedEmail, password: password) { (_, error) in
            if let error = error {
                print(error)
                /*
                 Error Domain=FIRAuthErrorDomain Code=17011 "There is no user record corresponding to this identifier. The user may have been deleted." UserInfo={NSLocalizedDescription=There is no user record corresponding to this identifier. The user may have been deleted., FIRAuthErrorUserInfoNameKey=ERROR_USER_NOT_FOUND}
                 */
                self.registerUserToFirebase(appUser: user, type: type, password: password)
                
            } else {
                self.manager.userId = user.userId
                if let currentUser = Auth.auth().currentUser {
                    
                    let request = currentUser.createProfileChangeRequest()
                    request.displayName = user.name
                    request.commitChanges { (error) in
                        guard error == nil else {
                            self.reportFirebaseRegisterError(error: error)
                            return }
                    }
                    createUserDocument(user: currentUser, account: user)
                }
            }
        }
    }
    
    private static func registerUserToFirebase(appUser: AppUserProfile, type: String , password: String) {
        let email = appUser.email
        let prefix = type.count > 0 ? "\(type)_" : ""
        let prefixedEmail = "\(prefix)\(email)"
        
        Auth.auth().createUser(withEmail: prefixedEmail, password: password) { (_, error) in
            if let currentUser = Auth.auth().currentUser {
                let request = currentUser.createProfileChangeRequest()
                request.displayName = appUser.name
                request.commitChanges { (error) in
                    guard error == nil else {
                        reportFirebaseRegisterError(error: error)
                        return }
                    
                }
                createUserDocument(user: currentUser, account: appUser)
                
            } else {
                reportFirebaseRegisterError(error: error)
                
            }
        }
    }
    
    private static func createUserDocument(
        user: Firebase.User,
        account: AppUserProfile) {
        
        var user = FSUser(uid: user.uid,
                          name: account.name,
                          serverId: account.userId,
                          currentLanguage: account.language)
        
        user.fcmToken = account.fcmToken
        let userDocument = self.db.collection(FSConstants.Collections.users).document(user.uid)
        userDocument.setData(user.toDictionary(), merge: true)
        updateUserOnServerWithFirebaseId(fid: userDocument.documentID)
        manager.myUser = user
    }
  
    
    private func updateUserProperity(fcm: String?, lang: String?) {
        guard myUser != nil else { return }
        var updates: [String: Any] = [:]
        
        if let fcm = fcm {
            updates["fcm_token"] = fcm
        }
        
        if let lang = lang {
            updates["lang"] = lang
        }
        guard !updates.keys.isEmpty else { return }
        updates["platform"] = "iOS"
        myUserRefrance.setData(updates.timestampDecorated(), merge: true)
    }
  
    
    public func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
  
    private func userDidUpdate() {
        
        let badge = myUser.badge
        NotificationCenter.default.post(name: .chatBadgeDidChangeNotification, object: nil, userInfo: ["badge": badge])
    }
    private func createListener() {
        
        myUserRefrance.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("myUserRefrance Error fetching document: \(error!)")
                return
            }
            guard let user = FSUser(document: document) else {
                print("myUserRefrance Document data was empty.")
                return
            }
            self.myUser = user
            
        }
        
    }
    
    func markChatRoomSeen(chatRoomReference: DocumentReference, userRefrance: DocumentReference) {
        chatRoomReference.getDocument(completion: { (snapshot, error) in
            
            if let snapshot = snapshot ,
                let room = OneToOneRoom(document: snapshot) {
                
                if room.seen == false {
                    userRefrance.getDocument { (snapshot, error) in
                        
                        if let userSnapShot = snapshot {
                            let data =  userSnapShot.data()
                            
                            if let badge = data?["badge"] as? Int, badge > 0 {
                                
                                // 1 set room isSeen = true
                                
                                // 2 decrement badge
                                
                                self.db.runTransaction({ (transaction, _) -> Any? in
                                    
                                    if badge > 0 {
                                        let update: Int64 = -1
                                        transaction.setData(
                                            ["badge": FieldValue.increment(update),
                                             "platform": "iOS"],
                                            forDocument: userRefrance, merge: true)
                                    }
                                    transaction.setData(
                                        ["seen": true,
                                         "platform": "iOS"], forDocument: chatRoomReference, merge: true)
                                    
                                    return nil
                                    
                                }) { (_, error) in
                                    
                                    if let error = error {
                                        print("Transaction failed: \(error)")
                                    } else {
                                        print("Transaction successfully committed! with  mychat room id :")
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                fatalError(" failed to get channel data")
            }
        })
        
    }
    
    public func initRoom(for oppositeUId: String ,oppositeName:String , complation:@escaping (String?)-> Void) {
        if myUser == nil {
            if let currentUser = Auth.auth().currentUser {
                var user = FSUser(uid: currentUser.uid,
                                  name: currentUser.displayName ?? "",
                                  serverId: nil,
                                  currentLanguage: nil)
                myUser = user
                
            }else {
                return
            }
        }
        
        readyToInitChannel(for: [], complation: complation)
    }
    
    private func readyToInitChannel(for users: [RoomUser], complation:@escaping (String?)-> Void) {
        
        
        var query: Query
        if users.count == 1 , let first = users.first {
            query = myUserRefrance.collection("chat_rooms").whereField("opposite_users.\(first.uid)", isEqualTo: true)
        }else {
            var filteredUsers = users
            let first = filteredUsers.removeFirst()

            let groups = myUserRefrance.collection("chat_rooms")
            query = groups.whereField("opposite_users.\(first.uid)", isEqualTo: true)
            filteredUsers.forEach({ (oppositeUser) in
                query = query.whereField("opposite_users.\(first.uid)", isEqualTo: true)
            })
        }
        
        query.getDocuments { (snapshot, error) in
            
            if let oldChat = snapshot?.documents.first {
                let chatId = oldChat.documentID
                self.prepareChannel(for: chatId, users: users, complation: complation)
            } else {
                self.createChannel(for: users, complation: complation)
            }
        }
    }
    
   
    /// users should contain all group or chat users include myself
       func createChannel(for users: [RoomUser], complation:@escaping (String?)-> Void) {
           
           let senders: [String] = users.map({$0.uid})
           
           let ref = channelsReference
               .addDocument(data: ["senders": senders,
                                   "creator":"iOS_service_provider"]) { (error) in
               if let error = error {
                   print("Error saving channel: \(error.localizedDescription)")
               }
           }
           
           self.prepareChannel(for: ref.documentID, users: users, complation: complation)
       }
    
    
    /// users should contain all group or chat users include myself
    func prepareChannel(for chatDocumentID: String, users: [RoomUser], complation:@escaping (String?)-> Void) {
        
        // Denormalize Data for each user
        
        let userRefrance = db.collection(FSConstants.Collections.users)
        
        db.runTransaction({ (transaction, _) -> Any? in
            
            for user in users {
                let oppositeUsers = users.filter({ $0.uid != user.uid })
                let userChatRooms = userRefrance
                    .document( [user.uid,
                                FSConstants.Collections.Users.chatRoomsSubCollection,
                                chatDocumentID]
                        .joined(separator: "/") )
                let userData = FSUser.chatRoomForOppositeUsers(users: oppositeUsers)
                transaction.setData(userData, forDocument: userChatRooms, merge: true)
            }
            return nil
            
        }) { (_, error) in
            
            if let error = error {
                print("Transaction failed: \(error)")
                complation(nil)
            } else {
                print("Transaction successfully committed! with chat room id : \(chatDocumentID)")
                complation(chatDocumentID)
            }
        }
    }
    
    func startChatForRoom(roomId: String, complation:@escaping ((user:FSUser, allusers: [FSUser], channel: Channel?)?) -> Void) {
        channelsReference.document(roomId).getDocument { (snapshot, error) in
            
            if let snapshot = snapshot ,
                let channel = Channel(document: snapshot) {
                //TODO: get channel users ids and fetch users from database
                self.db.collection(FSConstants.Collections.users)
                    .whereField(FieldPath.documentID(), in: channel.senders)
                    .getDocuments { (querySnapshot, error) in
                        
                        if let snapshot = querySnapshot {
                            
                            let users =  snapshot.documents
                                .map({FSUser.init(document: $0)}).compactMap({$0})
                            print("Chat room users: \(users.map({$0.name}).joined(separator: ", "))")
//                            let vc = ChatViewController(myUser: self.myUser, chatUsers: users, channel: channel)
                            complation((user: self.myUser, allusers: users, channel: channel))
                            
                        } else {
                            complation(nil)
                        }
                }
                
            } else {
                print(" failed to get channel data")
                complation(nil)
            }
        }
        
    }
}

extension Notification.Name {
    static let chatBadgeDidChangeNotification: Notification.Name = Notification.Name(rawValue: "chatBadgeDidChangeNotification")
}
