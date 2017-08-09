//
//  CreateGroupViewController.swift
//
//
//  Created by Mousa Khan on 2017-08-08.
//
//

import UIKit
import ChameleonFramework
import Firebase

class CreateGroupViewController: UIViewController {
    
    //TODO: Update the fields to match back-end data structure
    @IBOutlet weak var venueLogoImageView: UIImageView!
    @IBOutlet weak var venueDealDescriptionLabel: UILabel!
    @IBOutlet weak var venueDealValidityLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var venue : Venue?
    var deal : Deal?
    var user : UserInfo?
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        self.view.backgroundColor = FlatBlack().withAlphaComponent(0.9)
        
        // Change color of icon button, could probably make this into it's own helper function
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        // Set Logo
        let url = URL(string: venue!.logo)
        venueLogoImageView.kf.indicatorType = .activity
        venueLogoImageView.kf.setImage(with: url)
    
        venueDealDescriptionLabel.text = deal?.title
        venueDealValidityLabel.text = "Valid from \(deal!.validFrom) to \(deal!.validTo)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUser()
    }
    
    //MARK: IB Actions
    @IBAction func createGroupButtonPressed(_ sender: Any) {
        let groupRef = ref.child("groups")
        let id = groupRef.childByAutoId()
        
        
        self.ref.child("groups/\(id.key)").setValue(["created": ServerValue.timestamp(), "deal": deal!.id, "owner": self.user!.id, "venue": venue!.id])
        
        let userRef = ref.child("users/\(self.user!.id)/groups/\(id.key)")
        userRef.setValue(true)
        
        self.user!.groups[id.key] = ["created": ServerValue.timestamp(), "deal": deal!.id, "owner": self.user!.id, "venue": venue!.id]
        
        let controller = self.presentingViewController as! UINavigationController
        let groupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupCollectionViewController") as! GroupCollectionViewController
//        groupController.user = self.user!
        dismiss(animated: true) {
            controller.pushViewController(groupController, animated: true)
        }
    }
    @IBAction func dismissCreateGroupView(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Functions
    func formatDate(date : String) -> String {
        let formatter = DateFormatter()
        print(formatter.date(from: date)!)
        return ""
    }
    
    func setupUser() {
        let currentUser = Auth.auth().currentUser
        let userRef = ref.child("users/\(currentUser!.uid)")
        userRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
            let username = postDict["username"] as? String ?? ""
            let name = postDict["name"] as? String ?? ""
            let age = postDict["age"] as? String ?? ""
            let gender = postDict["gender"] as? String ?? ""
            let email = postDict["email"] as? String ?? ""
            let profile = postDict["profile"] as? String ?? ""
            let friends = postDict["friends"] as? Array<String> ?? []
            let groups = postDict["groups"] as? Dictionary<String, Any> ?? [:]
            
            self.user = UserInfo(username: username, name: name, id: (currentUser?.uid)!, age: age, email: email, gender: gender, profile: profile, groups: groups, friends: friends)
            
          
        })
    }
    
    
    
}
