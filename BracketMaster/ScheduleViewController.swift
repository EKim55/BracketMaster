//
//  ScheduleViewController.swift
//  BracketMaster
//
//  Created by CSSE Department on 5/15/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scheduleTable: UITableView!
    
    
    var competitionRef: CollectionReference!
    var matchRef: CollectionReference!
    var competition: Competition!
    var players = [Player]()
    var matches = [Match]()
    var numMatches = 0
    var generated = true
    
    let matchCellIdentifier = "MatchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        competitionRef = Firestore.firestore().collection("competitions")
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        scheduleTable.register(UITableViewCell.self, forCellReuseIdentifier: matchCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.matchRef = self.competitionRef.document(self.competition.id!).collection("matches")
        matchRef.addSnapshotListener { (query, error) in
            if error != nil { return }
            if (query!.isEmpty) {
                self.generated = false
            }
            if (self.competition == nil) {
                self.loadCompetition()
            }
            else {
                self.loadSelectedCompetition()
            }
        }

    }
    
    func loadSelectedCompetition() {
        self.titleLabel.text = self.competition.name
        self.scheduleTable.reloadData()
        self.getPlayers()
    }
    
    func loadCompetition() {
        let uidQuery = self.competitionRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid as Any).order(by: "created", descending: true).limit(to: 1)
        uidQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching competition: \(error.localizedDescription)")
                return
            }
            querySnapshot?.documentChanges.forEach({ (docChange) in
                self.matchRef = docChange.document.reference.collection("matches")
                self.competition = Competition(documentSnapshot: docChange.document)
                self.titleLabel.text = self.competition.name
            })
            self.scheduleTable.reloadData()
            self.getPlayers()
        }
    }
    
    func getPlayers() {
        let playerRef = self.competitionRef.document(self.competition.id!).collection("players")
        self.players.removeAll()
        for i in 0..<self.competition.numPlayers {
            playerRef.document("Player \(i + 1)").getDocument { (document, error) in
                if let document = document, document.exists {
                    self.players.append(Player(playerName: document.data()!["name"] as! String,
                                               numWins: document.data()!["wins"] as! Int, numLosses: document.data()!["losses"] as! Int))
                    self.scheduleTable.reloadData()
                } else {
                    print("Document does not exist")
                }
                self.scheduleTable.reloadData()
                if self.players.count == self.competition.numPlayers {
                    if (!self.generated) {
                        self.generateMatches()
                    } else {
                        self.addMatches()
                    }
                }
            }
        }
    }
    
    func addMatches() {
        self.matches.removeAll()
        for i in 0..<self.numMatches {
            self.matchRef.document("Match \(i + 1)").getDocument { (document, error) in
                if let document = document, document.exists {
                    let playerOneName = document.data()!["playerOne"] as! String
                    let playerTwoName = document.data()!["playerTwo"] as! String
                    var playerOne: Player!
                    var playerTwo: Player!
                    for j in 0..<self.players.count {
                        if self.players[j].name == playerOneName {
                            playerOne = self.players[j]
                        } else if self.players[j].name == playerTwoName {
                            playerTwo = self.players[j]
                        }
                    }
                    let match = Match(playerOne: playerOne, playerTwo: playerTwo)
                    match.matchNum = i + 1
                    if (document.data()!["result"] as? Bool != nil) {
                        match.setResult(document.data()!["result"] as! Bool)
                    }
                    self.matches.append(match)
                    self.matches.sort(by: { (m1, m2) -> Bool in
                        return m1.matchNum < m2.matchNum
                    })
                    self.scheduleTable.reloadData()
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func generateMatches() {
        self.matches.removeAll()
        for i in 0..<(self.players.count - 1) {
            for j in i..<(self.players.count - 1) {
                self.matches.append(Match(playerOne: self.players[i], playerTwo: self.players[j + 1]))
                self.matches.append(Match(playerOne: self.players[j + 1], playerTwo: self.players[i]))
            }
        }
        self.matches.shuffle()
        for i in 0..<self.matches.count {
            matchRef.document("Match \(i + 1)").setData(["playerOne": self.matches[i].playerOne.name,
                                                         "playerTwo": self.matches[i].playerTwo.name,
                                                         "result": self.matches[i].result as Any,
                                                         "matchNum": i + 1])
        }
        generated = true
        self.scheduleTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.numMatches = 0
        if (self.competition == nil) {
            return numMatches
        }
        for i in 0..<self.competition.numPlayers {
            numMatches = numMatches + i
        }
        numMatches = numMatches * 2
        return numMatches
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let i = indexPath.row
        var cell: UITableViewCell?
        if tableView == self.scheduleTable {
            cell = tableView.dequeueReusableCell(withIdentifier: matchCellIdentifier, for: indexPath)
            if (self.matches.count > i) {
                if (self.matches[i].result == nil) {
                    cell!.textLabel!.text = "\(self.matches[i].playerOne.name!) (\(self.matches[i].playerOne.wins!) - \(self.matches[i].playerOne.losses!)) vs. \(self.matches[i].playerTwo.name!) (\(self.matches[i].playerTwo.wins!) - \(self.matches[i].playerTwo.losses!))"
                } else if (self.matches[i].result == true) {
                    cell!.textLabel?.text = "\(self.matches[i].playerOne.name!) (\(self.matches[i].playerOne.wins!) - \(self.matches[i].playerOne.losses!)) beat \(self.matches[i].playerTwo.name!) (\(self.matches[i].playerTwo.wins!) - \(self.matches[i].playerTwo.losses!))"
                    cell?.selectionStyle = UITableViewCellSelectionStyle.none
                } else {
                    cell!.textLabel?.text = "\(self.matches[i].playerOne.name!) (\(self.matches[i].playerOne.wins!) - \(self.matches[i].playerOne.losses!)) lost to \(self.matches[i].playerTwo.name!) (\(self.matches[i].playerTwo.wins!) - \(self.matches[i].playerTwo.losses!))"
                    cell?.selectionStyle = UITableViewCellSelectionStyle.none
                }
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let match = matches[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.selectionStyle != UITableViewCellSelectionStyle.none) {
            showActionMenu(match, cell!)
        }
        
        cell?.isSelected = false
        self.scheduleTable.reloadData()
    }
    
    func showActionMenu(_ match: Match, _ cell: UITableViewCell) {
        let menu: UIAlertController = UIAlertController(title: "Who won?", message: nil, preferredStyle: .actionSheet)
        var winningPlayer: Player?
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            return
        }
        
        let player1WinsButton = UIAlertAction(title: "\(match.playerOne.name!) Wins!", style: .default) { (action) in
            match.result = true
            winningPlayer = match.playerOne
            self.playerWins(match, winningPlayer!, cell)
        }
        menu.addAction(player1WinsButton)
        
        let player2WinsButton = UIAlertAction(title: "\(match.playerTwo.name!) Wins!", style: .default) { (action) in
            match.result = false
            winningPlayer = match.playerTwo
            self.playerWins(match, winningPlayer!, cell)
        }
        menu.addAction(player2WinsButton)
        menu.addAction(cancelButton)
        
        self.present(menu, animated: true, completion: nil)
    }
    
    func playerWins(_ match: Match, _ player: Player, _ cell: UITableViewCell) {
        let playersRef: CollectionReference = self.competitionRef.document(self.competition.id!).collection("players")
        let loser: Player!
        if (player == match.playerOne) {
            loser = match.playerTwo
        } else {
            loser = match.playerOne
        }
        for i in 0..<self.competition.numPlayers {
            playersRef.document("Player \(i + 1)").getDocument { (document, error) in
                if let document = document, document.exists {
                    if document.data()!["name"] as? String == player.name {
                        player.wins = player.wins + 1
                        playersRef.document("Player \(i + 1)").setData(["wins": player.wins], merge: true)
                        self.scheduleTable.reloadData()
                    }
                    else if document.data()!["name"] as? String == loser?.name {
                        loser.losses = loser.losses + 1
                        playersRef.document("Player \(i + 1)").setData(["losses": loser.losses], merge: true)
                        self.scheduleTable.reloadData()
                    }
                } else {
                    print("Document does not exist")
                }
            }
            if (player == match.playerOne) {
                cell.textLabel?.text = "\(player.name!) (\(player.wins!) - \(player.losses!)) beat \(loser.name!) (\(loser.wins!) - \(loser.losses!))"
            } else {
                cell.textLabel?.text = "\(player.name!) (\(player.wins!) - \(player.losses!)) lost to \(loser.name!) (\(loser.wins!) - \(loser.losses!))"
            }
            self.scheduleTable.reloadData()
        }
        for i in 0..<self.numMatches {
            self.matchRef.document("Match \(i + 1)").getDocument { (document, error) in
                if let document = document, document.exists {
                    if document.data()!["playerOne"] as? String == match.playerOne.name {
                        if document.data()!["playerTwo"] as? String == match.playerTwo.name {
                            self.matchRef.document("Match \(i + 1)").setData(["result": match.result!], merge: true)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
}

extension Array {
    mutating func shuffle() {
        for _ in indices {
            sort { (_,_) in arc4random() < arc4random()}
        }
    }
}
