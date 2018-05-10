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
    var participants: [String]?
    var numParticipants: Int!
    
    let createdKey = "created"
    let isLeagueKey = "isLeague"
    let participantsKey = "participants"
    let numParticipantsKey = "numParticipants"
    
    init(isLeague: Bool, people: [String], numberOfParticipants: Int) {
        self.isLeague = isLeague
        self.numParticipants = numberOfParticipants
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
        self.numParticipants = data[numParticipantsKey] as! Int
        self.participants = data[participantsKey] as? [String]
        if data[createdKey] != nil {
            self.created = data[createdKey] as! Date?
        }
    }
    
    var data: [String: Any?] {
        return [isLeagueKey: self.isLeague,
                createdKey: self.created,
                numParticipantsKey: self.numParticipants,
                participantsKey: self.participants]
    }
}
