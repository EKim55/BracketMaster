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
    var isLeague: Bool
    var participants: [String]!
    var numParticipants: Int!
    var name: String!
    var created: Date!
    
    let createdKey = "created"
    let isLeagueKey = "isLeague"
    let participantsKey = "participants"
    let numParticipantsKey = "numParticipants"
    let nameKey = "name"
    
    init(isLeague: Bool, people: [String], numberOfParticipants: Int, competitionName: String) {
        self.isLeague = isLeague
        self.numParticipants = numberOfParticipants
        self.name = competitionName
        self.participants = people
        self.created = Date()
        
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.isLeague = data[isLeagueKey] as! Bool
        self.numParticipants = data[numParticipantsKey] as! Int
        self.participants = data[participantsKey] as? [String]
        self.name = data[nameKey] as! String
        if data[createdKey] != nil {
            self.created = data[createdKey] as! Date?
        }
    }
    
    var data: [String: Any] {
        return [isLeagueKey: self.isLeague,
                createdKey: self.created,
                numParticipantsKey: self.numParticipants,
                participantsKey: self.participants,
                nameKey: self.name]
    }
}
