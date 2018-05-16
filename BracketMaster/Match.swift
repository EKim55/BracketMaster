//
//  Match.swift
//  BracketMaster
//
//  Created by CSSE Department on 5/16/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit

class Match: NSObject {
    var playerOne: Player!
    var playerTwo: Player!
    var result: Bool? //true if player 1 wins, false if player 2 wins
    var matchNum: Int!
    
    init(playerOne: Player, playerTwo: Player) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
    }
    
    func setResult(_ result: Bool) {
        self.result = result
    }
    
}
