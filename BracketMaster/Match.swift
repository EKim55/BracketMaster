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
    
    init(playerOne: Player, playerTwo: Player) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
    }
    
}
