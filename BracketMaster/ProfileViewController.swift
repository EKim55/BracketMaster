//
//  ProfileViewController.swift
//  BracketMaster
//
//  Created by Praneet Chakraborty on 4/26/18.
//  Copyright © 2018 CSSE Department. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    var profileStorageRef: StorageReference!
    var profileDocRef: DocumentReference!
    var profileListener: ListenerRegistration!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        profileStorageRef = Storage.storage().reference(withPath: uid)
        profileDocRef = Firestore.firestore().collection("profile").document(uid)
        print("\(uid)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileListener = profileDocRef.addSnapshotListener({ (snapshot, error) in
            if let error = error {
                print("Error getting the Firestore document \(error.localizedDescription)")
            }
            if let url = snapshot?.get("url") as? String {
                if let imgURL = URL(string: url) {
                    DispatchQueue.global().async {
                        do {
                            let data = try Data(contentsOf: imgURL)
                            DispatchQueue.main.async {
                                self.imageView.image = UIImage(data: data)
                            }
                        } catch {
                            print("Error downloading image: \(error.localizedDescription)")
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func pressedSignOut(_ sender: Any) {
        appDelegate.handleLogout()
    }
    @IBAction func pressedProfileButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func uploadImage(_ image: UIImage) {
        guard let data = UIImageJPEGRepresentation(image, 0.5) else { return }
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        let uploadTask = profileStorageRef.putData(data, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("Error with upload \(error.localizedDescription)")
            }
        }
        uploadTask.observe(StorageTaskStatus.success) { (snapshot) in
            self.profileStorageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("Error getting the download url. \(error.localizedDescription)")
                }
                if let url = url {
                    self.profileDocRef.setData(["url" : url.absoluteString])
                }
            })
        }
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uploadImage(image)
        }
        picker.dismiss(animated: true)
    }
}
