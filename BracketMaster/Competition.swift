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
    var players: [Player]?
    var numPlayers: Int!
    var name: String!
    var created: Date!
    var uid: String!
    
    let createdKey = "created"
    let isLeagueKey = "isLeague"
    let playersKey = "players"
    let numPlayersKey = "numPlayers"
    let nameKey = "name"
    let uidKey = "uid"
    
    init(isLeague: Bool, numberOfPlayers: Int, competitionName: String, userID: String) {
        self.isLeague = isLeague
        self.numPlayers = numberOfPlayers
        self.name = competitionName
        //self.players = people
        self.uid = userID
        self.created = Date()
        
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.isLeague = data[isLeagueKey] as! Bool
        self.numPlayers = data[numPlayersKey] as! Int
        //self.players = data[playersKey] as? [Player]
        self.name = data[nameKey] as! String
        self.uid = data[uidKey] as! String
        if data[createdKey] != nil {
            self.created = data[createdKey] as! Date?
        }
    }
    
    var data: [String: Any] {
        return [isLeagueKey: self.isLeague,
                createdKey: self.created,
                numPlayersKey: self.numPlayers,
                nameKey: self.name,
                uidKey: self.uid]
    }
    
    public func setNames(_ newNames: [String]) {
        for i in 0..<players!.count {
            players![i].name = newNames[i]
        }
    }
}
