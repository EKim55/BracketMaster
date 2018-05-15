//
//  Player.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 5/15/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import Foundation

class Player: NSObject {
    var name: String!
    var wins: Int!
    var losses: Int!
    
    init(playerName: String, numWins: Int, numLosses: Int) {
        self.name = playerName
        self.wins = numWins
        self.losses = numLosses
    }
}
