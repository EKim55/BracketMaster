//
//  HomeViewController.swift
//  BracketMaster
//
//  Created by CSSE Department on 4/26/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewController: UITableViewController {
    
    var competitionsRef: CollectionReference!
    var competitionsListener: ListenerRegistration!
        
    @IBOutlet weak var addButton: UIButton!
    
    let competitionCellIdentifier = "CompetitionCell"
    let noCompetitionsCellIdentifier = "NoCompetitionsCell"
    var competitions = [Competition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Competitions"
        competitionsRef = Firestore.firestore().collection("competitions")
        print("addButton: \(addButton.isEnabled)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        competitions.removeAll()
        loadAllCompetitions()
    }
    
    func loadAllCompetitions() {
        competitionsListener = competitionsRef.order(by: "created", descending: true).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching competitions for table: \(String(describing: error?.localizedDescription))")
                return
            }
            snapshot.documentChanges.forEach({ (docChange) in
                if docChange.type == .added {
                    print("New competition: \(docChange.document.data())")
                    self.competitionAdded(docChange.document)
                } else if docChange.type == .modified {
                    print("Modified competition: \(docChange.document.data())")
                    self.competitionModified(docChange.document)
                } else if docChange.type == .removed {
                    print("Removed competition: \(docChange.document.data())")
                    self.competitionRemoved(docChange.document)
                }
                self.competitions.sort(by: { (c1, c2) -> Bool in
                    return c1.created > c2.created
                })
            })
            self.tableView.reloadData()
        })
    }
    
    func competitionAdded(_ document: DocumentSnapshot) {
        let newComp = Competition(documentSnapshot: document)
        competitions.append(newComp)
    }
    
    func competitionModified(_ document: DocumentSnapshot) {
        let modifiedComp = Competition(documentSnapshot: document)
        
        for comp in competitions {
            if comp.id == modifiedComp.id {
                comp.name = modifiedComp.name
                comp.participants = modifiedComp.participants     // cannot modify number of participants after creation
                break
            }
        }
    }
    
    func competitionRemoved(_ document: DocumentSnapshot) {
        let removedComp = Competition(documentSnapshot: document)
        for i in 0..<competitions.count {
            if competitions[i].id == removedComp.id {
                competitions.remove(at: i)
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        competitionsListener.remove()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(competitions.count, 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if competitions.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: noCompetitionsCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: competitionCellIdentifier, for: indexPath)
            cell.textLabel?.text = competitions[indexPath.row].name
        }
        return cell
    }
}
