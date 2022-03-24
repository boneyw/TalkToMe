//
//  DatabaseManager.swift
//  TalkToMe
//
//  Created by william boney on 3/24/22.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()

}

//Mark: - Account managment
extension DatabaseManager{
    public func userExists(with email: String, completion: @escaping((Bool)-> Void)){
        database.child(email).observeSingleEvent(of: .value, with: {snapshot in
            guard  snapshot.value as? String != nil else{
                completion (false)
                return
            }
            completion(true)
        })
    }
    
    ///inserts new user to database
    public func insertUser(with user :ChatAppUser){
        
        database.child(user.emailAddress).setValue([
            "first_name": user.firstname,
            "last_name": user.lastname,
            
        
        ])
    }
}

struct ChatAppUser{
    let firstname: String
    let lastname: String
    let emailAddress: String
    //let profilePicURL: String
}

