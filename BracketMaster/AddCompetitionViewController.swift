//
//  AddCompetitionViewController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 5/10/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class AddCompetitionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var competitionRef: CollectionReference!

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    //new league variables to be filled out
    var competitionName: String = ""
    var numPlayers: Int = 0
    
    let backToHomeSegueIdentifier = "BackToHomeSegue"
    
    let numberOfParticipants = ["2", "3", "4", "5", "6", "7", "8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        label.text = "How many players are part of this league?"
        label.sizeToFit()
        pickerView.isHidden = false
        textField.isHidden = true
        doneButton.isHidden = true
        textField.text = ""
        competitionRef = Firestore.firestore().collection("competitions")
    }
    
    @IBAction func pressedDone(_ sender: Any) {
        competitionName = textField.text!
        var players = [Player]()
        for i in 0..<numPlayers {
            let player = Player(playerName: "Player \(i+1)", numWins: 0, numLosses: 0)
            players.append(player)
        }
        let newCompetition = Competition(isLeague: true, numberOfPlayers: numPlayers, competitionName: competitionName, userID: (Auth.auth().currentUser?.uid)!)
        let docRef: DocumentReference = competitionRef.addDocument(data: newCompetition.data)
        let playersRef: CollectionReference = docRef.collection("players")
        newCompetition.playersCollectionRef = playersRef
        
        for i in 0..<players.count {
            playersRef.document("Player \(i+1)").setData([
                "name" : players[i].name,
                "wins" : players[i].wins,
                "losses" : players[i].losses
            ]) { (error) in
                if let error = error {
                    print("Error making documents for individual players: \(error.localizedDescription)")
                } else {
                    print("Successfully made document for Player \(i+1)")
                }
            }
        }
    }
    
    @IBAction func pressedBack(_ sender: Any) {
        textField.text = "    "
        performSegue(withIdentifier: backToHomeSegueIdentifier, sender: sender)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfParticipants.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numberOfParticipants[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numPlayers = row + 2
        label.text = "What would you like to call this league?"
        pickerView.isHidden = true
        textField.isHidden = false
        textField.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 1)
        doneButton.isHidden = false
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if textField.text == "" {
            pressedDone((Any).self)
        }
    }
}
