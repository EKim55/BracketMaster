//
//  CompetitionViewController.swift
//  BracketMaster
//
//  Created by CSSE Department on 5/14/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class CompetitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankTable: UITableView!
    @IBOutlet weak var playerTable: UITableView!
    @IBOutlet weak var winsTable: UITableView!
    @IBOutlet weak var lossTable: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var competitionRef: CollectionReference!
    var competition: Competition!
    
    let rankCellIdentifier = "RankCell"
    let playerCellIdentifier = "PlayerCell"
    let winsCellIdentifier = "WinsCell"
    let lossCellIdentifier = "LossCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.black

        competitionRef = Firestore.firestore().collection("competitions")
        rankTable.delegate = self
        rankTable.dataSource = self
        rankTable.register(UITableViewCell.self, forCellReuseIdentifier: rankCellIdentifier)
        playerTable.delegate = self
        playerTable.dataSource = self
        playerTable.register(UITableViewCell.self, forCellReuseIdentifier: playerCellIdentifier)
        winsTable.delegate = self
        winsTable.dataSource = self
        winsTable.register(UITableViewCell.self, forCellReuseIdentifier: winsCellIdentifier)
        lossTable.delegate = self
        lossTable.dataSource = self
        lossTable.register(UITableViewCell.self, forCellReuseIdentifier: lossCellIdentifier)
        
        rankTable.isScrollEnabled = false
        rankTable.allowsSelection = false
        playerTable.isScrollEnabled = false
        playerTable.allowsSelection = false
        winsTable.isScrollEnabled = false
        winsTable.allowsSelection = false
        lossTable.isScrollEnabled = false
        lossTable.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let uidQuery = self.competitionRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid as Any).order(by: "created", descending: true).limit(to: 1)
        uidQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching competition: \(error.localizedDescription)")
                return
            }
            querySnapshot?.documentChanges.forEach({ (docChange) in
                self.competition = Competition(documentSnapshot: docChange.document)
            })
        }
    }
    
//    func fillTables(_ document: DocumentSnapshot) {
//        self.competition = Competition(documentSnapshot: document)
//        self.titleLabel.text = self.competition.name
//        for i in 0..<self.competition.numParticipants {
//            let indexPath = IndexPath(row: i, section: 0)
//            let cell = rankTable.cellForRow(at: indexPath)
//            cell?.textLabel?.text = "\(i + 1)"
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.competition == nil) {
            return 10
        }
        return self.competition.numPlayers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let i = indexPath.row
        var cell: UITableViewCell?
        if tableView == self.rankTable {
            cell = tableView.dequeueReusableCell(withIdentifier: rankCellIdentifier, for: indexPath)
            cell!.textLabel!.text = "\(i + 1)"
        }
        if tableView == self.playerTable {
            cell = tableView.dequeueReusableCell(withIdentifier: playerCellIdentifier, for: indexPath)
            cell!.textLabel!.text = "0"
        }
        if tableView == self.winsTable {
            cell = tableView.dequeueReusableCell(withIdentifier: winsCellIdentifier, for: indexPath)
            cell!.textLabel!.text = "1"
        }
        
        if tableView == self.lossTable {
            cell = tableView.dequeueReusableCell(withIdentifier: lossCellIdentifier, for: indexPath)
            cell!.textLabel!.text = "2"
        }
        return cell!
    }
    
}
