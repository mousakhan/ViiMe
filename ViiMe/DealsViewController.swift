//
//  DealsViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-22.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import SCLAlertView
import Firebase

class DealsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let reuseIdentifier = "UITableViewCell"
    var venue : Venue?
    var user : UserInfo?
    var ref: DatabaseReference!
    var groups: Array<Any>?
    
    @IBOutlet weak var venueInfoView: UIView!
    @IBOutlet weak var aboutThisVenueLabel: UILabel!
    @IBOutlet weak var venueDescriptionLabel: UILabel!
    @IBOutlet weak var venueDeals: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var venueTypeLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var venueDealsLabel: UILabel!
    @IBOutlet weak var cuisineIcon: UIImageView!
    @IBOutlet weak var distanceIcon: UIImageView!
    @IBOutlet weak var venueTypeIcon: UIImageView!
    @IBOutlet weak var priceIcon: UIImageView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var websiteIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!
    @IBOutlet weak var venueLogo: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var venueDescriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupUser()
        initDealsView()
        
    }
    
    
    //MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venue!.deals.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.backgroundColor = FlatBlackDark()
        cell.textLabel?.text = venue?.deals[indexPath.row].title
        cell.textLabel?.textColor = FlatWhite()
        cell.textLabel?.font = cell.textLabel?.font.withSize(12 )
        cell.detailTextLabel?.text = "Group of \(venue!.deals[indexPath.row].numberOfPeople) required"
        cell.detailTextLabel?.textColor = FlatWhite()
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.withSize(10)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = FlatPurpleDark()
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
            kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Create", backgroundColor: FlatPurple())    {
            let groupRef = self.ref.child("groups")
            let id = groupRef.childByAutoId()
            
            self.ref.child("groups/\(id.key)").setValue(["created": ServerValue.timestamp(), "deal": self.venue!.deals[indexPath.row].id, "owner": self.user!.id, "venue": self.venue!.id])
            let userRef = self.ref.child("users/\(self.user!.id)/groups/\(id.key)")
            userRef.setValue(true)
            
            self.groups?.append(["created": ServerValue.timestamp(), "deal": self.venue!.deals[indexPath.row].id, "owner": self.user!.id, "venue": self.venue!.id])
            
            self.performSegue(withIdentifier: "GroupCollectionViewSegue", sender: nil)
        }
        
        alertView.addButton("Cancel", backgroundColor: FlatRed())   {}
        
        alertView.showInfo("Create Group", subTitle: "Purchase a Medium Pizza (5 Toppings), Get 10 Free wings. Valid from \(venue!.deals[indexPath.row].validFrom) to \(venue!.deals[indexPath.row].validTo)")
        
        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
        
    }
    //MARK: Helper
    func addIcon(name: String, imageView : UIImageView) {
        imageView.image = UIImage(named: name)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = FlatGray()
    }
    
    func initDealsView() {
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        self.navigationItem.title = venue!.name
        
        aboutThisVenueLabel.addBottomBorderWithColor(color: FlatGray(), width: 1)
        
        let url = URL(string: venue!.logo)
        venueLogo.kf.indicatorType = .activity
        venueLogo.kf.setImage(with: url)
        
        venueDescriptionLabel.text = venue!.description
        priceLabel.text = venue!.price
        addressLabel.text = venue!.address
        venueTypeLabel.text = venue!.type
        cuisineLabel.text = venue!.cuisine
        websiteLabel.text = venue!.website
        phoneNumberLabel.text = venue!.number
        
        venueDealsLabel.text = "\(venue!.deals.count) Venue Deals"
        
        // Adding icon and changing color
        addIcon(name: "phone", imageView: phoneIcon)
        addIcon(name: "website", imageView: websiteIcon)
        addIcon(name: "address", imageView: addressIcon)
        addIcon(name: "distance", imageView: distanceIcon)
        addIcon(name: "cuisine", imageView: cuisineIcon)
        addIcon(name: "price", imageView: priceIcon)
        addIcon(name: "type", imageView: venueTypeIcon)
    }
    
    
    func setupUser() {
        let currentUser = Auth.auth().currentUser
        let userRef = ref.child("users/\(currentUser!.uid)")
        
        userRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let username = postDict["username"] as? String ?? ""
            let name = postDict["name"] as? String ?? ""
            let age = postDict["age"] as? String ?? ""
            let gender = postDict["gender"] as? String ?? ""
            let email = postDict["email"] as? String ?? ""
            let profile = postDict["profile"] as? String ?? ""
            let friends = postDict["friends"] as? Array<String> ?? []
            let groupIDs = postDict["groups"] as? Dictionary<String, Any> ?? [:]
            
            self.getGroups(ids: groupIDs as NSDictionary, completionHandler: { (isComplete, groups) in
                if (isComplete) {
                    self.groups = groups

                }
            })
            
            self.user = UserInfo(username: username, name: name, id: currentUser!.uid, age: age, email: email, gender: gender, profile: profile, groups: groupIDs, friends: friends)
        })
    }
    
    
    // This'll fetch all the informationg relating to the groups of this venue for the user
    func getGroups(ids : NSDictionary, completionHandler: @escaping (_ isComplete: Bool, _ groups:Array<Any>) -> ()){
        var groups : Array<Any> = []
        // Query for the groups of this venue
        let ref = Database.database().reference().child("groups").queryOrdered(byChild: "venue").queryEqual(toValue : self.venue!.id)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            groups = []
            let enumerator = snapshot.children
            while let group = enumerator.nextObject() as? DataSnapshot {
                let value = group.value as? NSDictionary
                let deal = value?["deal"] ?? ""
                let created = value?["created"] ?? ""
                let owner = value?["owner"] ?? ""
                let groupUsers = value?["users"] as? Dictionary<String, Bool> ?? [:]
                var userIds = [String()]
                
                for (key, _) in groupUsers {
                    userIds.append(key)
                }
                
                var dict = [String: Any]()
                dict["deal"] = deal
                dict["users"] = userIds
                dict["created"] = created
                dict["owner"] = owner
                groups.append(dict)
             
            }
             completionHandler(true, groups)
        })
        
    }
    
 
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GroupCollectionViewSegue") {
            let destVC = segue.destination as? GroupCollectionViewController
            destVC?.groups = self.groups
        }
    }
    
    
}
