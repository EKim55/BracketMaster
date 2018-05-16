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
    var competition: Competition!
    var players = [Player]()
    var matches = [Match]()
    var numMatches = 0
    
    let matchCellIdentifier = "MatchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        competitionRef = Firestore.firestore().collection("competitions")
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        scheduleTable.register(UITableViewCell.self, forCellReuseIdentifier: matchCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCompetition()
    }
    
    func loadCompetition() {
        let uidQuery = self.competitionRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid as Any).order(by: "created", descending: true).limit(to: 1)
        uidQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching competition: \(error.localizedDescription)")
                return
            }
            querySnapshot?.documentChanges.forEach({ (docChange) in
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
                    print("\(i)")
                } else {
                    print("Document does not exist")
                }
                self.scheduleTable.reloadData()
                if self.players.count == self.competition.numPlayers {
                    self.generateMatches()
                }
            }
        }
    }
    
    func generateMatches() {
        for i in 0..<(self.players.count - 1) {
            for j in i..<(self.players.count - 1) {
                self.matches.append(Match(playerOne: self.players[i], playerTwo: self.players[j + 1]))
                self.matches.append(Match(playerOne: self.players[j + 1], playerTwo: self.players[i]))
            }
        }
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
                cell!.textLabel!.text = "\(self.matches[i].playerOne.name!) (\(self.matches[i].playerOne.wins!) - \(self.matches[i].playerOne.losses!)) vs. \(self.matches[i].playerTwo.name!) (\(self.matches[i].playerTwo.wins!) - \(self.matches[i].playerTwo.losses!))"
            }
        }
        return cell!
    }
    
}

extension Array {
    mutating func shuffle() {
        for _ in indices {
            sort { (_,_) in arc4random() < arc4random()}
        }
    }
}
