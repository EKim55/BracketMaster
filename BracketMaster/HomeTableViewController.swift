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
    
    var window: UIWindow?
    
    var competitionsRef: CollectionReference!
        
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    let competitionCellIdentifier = "CompetitionCell"
    let noCompetitionsCellIdentifier = "NoCompetitionsCell"
    let tabBarSegueIdentifier = "TabBarSegue"
    var competitions = [Competition]()
    var canEdit = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Competitions"
        competitionsRef = Firestore.firestore().collection("competitions")
        //currentUser = (Auth.auth().currentUser?.uid)!
    }
    
    @IBAction func pressedEdit(_ sender: Any) {
        if !canEdit {
            canEdit = true
            editButton.setTitle("Done", for: .normal)
        } else {
            canEdit = false
            editButton.setTitle("Edit", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear called")
        super.viewWillAppear(animated)
        competitions.removeAll()
        loadCompetitions()
        tableView.reloadData()
    }
    
    func loadCompetitions() {
        print("called loadCompetitions")
        let uidQuery = self.competitionsRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid as Any)
        competitions.removeAll()
        
        uidQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching competitions for table: \(error.localizedDescription)")
                return
            }
            querySnapshot?.documentChanges.forEach({ (docChange) in
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
        }
    }
    
    func competitionAdded(_ document: DocumentSnapshot) {
        let newComp = Competition(documentSnapshot: document)
        competitions.append(newComp)
    }
    
    func competitionModified(_ document: DocumentSnapshot) {
        //competitions can't be modified
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
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if competitions.count == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if competitions.count == 0 {
            tableView.cellForRow(at: indexPath)?.isSelected = false
            return
        }
        let comp = competitions[indexPath.row]
        if canEdit {
            showEditDialog(comp)
        } else {
            tableView.cellForRow(at: indexPath)?.isSelected = false
            ((self.tabBarController?.viewControllers![1] as! PageViewController).orderedViewControllers[0] as! CompetitionViewController).competition = self.competitions[indexPath.row]
            ((self.tabBarController?.viewControllers![1] as! PageViewController).orderedViewControllers[1] as! ScheduleViewController).competition = self.competitions[indexPath.row]
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return competitions.count > 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let competitionToDelete = competitions[indexPath.row]
            competitionsRef.document(competitionToDelete.id!).delete()
            loadCompetitions()
        }
    }
    
    func showEditDialog(_ comp: Competition) {
        print("Entered edit dialog")
        let alertController = UIAlertController(title: "Edit Names of the Players", message: "Please fill in all fields", preferredStyle: .alert)
        let rows = comp.numPlayers!
        for i in 0..<rows {
            alertController.addTextField { (textField) in
                textField.placeholder = "Player \(i+1)'s Name"
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let changeNamesAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            var newNames = [String]()
            for i in 0..<rows {
                let textField = alertController.textFields![i]
                newNames.append(textField.text!)
                print(newNames[i])
            }
            let matchRef = self.competitionsRef.document(comp.id!).collection("matches")
            let playersRef: CollectionReference = self.competitionsRef.document(comp.id!).collection("players")
            for i in 0..<rows {
                var playerName: String?
                playersRef.document("Player \(i + 1)").getDocument(completion: { (document, error) in
                    if let document = document, document.exists {
                        playerName = document.data()!["name"] as? String
                        
                        matchRef.whereField("playerOne", isEqualTo: playerName!).getDocuments(completion: { (query, error) in
                            query?.documentChanges.forEach({ (docChange) in
                                docChange.document.reference.setData(["playerOne": newNames[i]], merge: true)
                            })
                        })
                        matchRef.whereField("playerTwo", isEqualTo: playerName!).getDocuments(completion: { (query, error) in
                            query?.documentChanges.forEach({ (docChange) in
                                docChange.document.reference.setData(["playerTwo": newNames[i]], merge: true)
                            })
                        })
                        playersRef.document("Player \(i+1)").setData(["name" : newNames[i]], merge: true)
                    }
                })
            }
        }
        alertController.addAction(changeNamesAction)
        present(alertController, animated: true, completion: nil)
    }
}
