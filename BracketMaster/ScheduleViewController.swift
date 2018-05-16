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
    var generated = false
    
    let matchCellIdentifier = "MatchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        competitionRef = Firestore.firestore().collection("competitions")
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        scheduleTable.register(UITableViewCell.self, forCellReuseIdentifier: matchCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.competition == nil) {
            loadCompetition()
        }
        else {
            loadSelectedCompetition()
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
                    }
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
                                                         "result": self.matches[i].result])
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
                }
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let match = matches[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        showActionMenu(match, cell!)
        
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
                        playersRef.document("Player \(i + 1)").setData(["wins": player.wins + 1], merge: true)
                    }
                    else if document.data()!["name"] as? String == loser?.name {
                        playersRef.document("Player \(i + 1)").setData(["losses": player.losses + 1], merge: true)
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
