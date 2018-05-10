//
//  competition.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 5/1/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import Foundation
import Firebase

class Competition: NSObject {
    var id: String?
    var created: Date!
    var isLeague: Bool
    var participants: [String]
    
    let createdKey = "created"
    let isLeagueKey = "isLeague"
    let participantsKey = "participants"
    
    init(isLeague: Bool, people: [String]) {
        self.isLeague = isLeague
        if !isLeague {
            self.participants = people
        } else {
            self.participants = people
        }
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.isLeague = data[isLeagueKey] as! Bool
        self.participants = data[participantsKey] as! [String]
        if data[createdKey] != nil {
            self.created = data[createdKey] as! Date?
        }
    }
    
    var data: [String: Any?] {
        return [isLeagueKey: self.isLeague,
                createdKey: self.created,
                participantsKey: self.participants]
    }
}
