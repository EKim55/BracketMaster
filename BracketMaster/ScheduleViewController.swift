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
    
    let matchCellIdentifier = "MatchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        competitionRef = Firestore.firestore().collection("competitions")
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        scheduleTable.register(UITableViewCell.self, forCellReuseIdentifier: matchCellIdentifier)
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
                } else {
                    print("Document does not exist")
                }
                print("\(self.players)")
                self.scheduleTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.competition == nil) {
            return 0
        }
        return self.competition.numPlayers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}
