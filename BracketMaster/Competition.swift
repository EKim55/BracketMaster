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
    
    let createdKey = "created"
    let isLeagueKey = "isLeague"
    
    init(isLeague: Bool) {
        self.isLeague = isLeague
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.isLeague = data[isLeagueKey] as! Bool
        if data[createdKey] != nil {
            self.created = data[createdKey] as! Date!
        }
    }
    
    var data: [String: Any?] {
        return [isLeagueKey: self.isLeague,
                createdKey: self.created]
    }
}
