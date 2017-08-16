//
//  GroupCollectionViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-08.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase

private let reuseIdentifier = "GroupCategoryCell"

class GroupCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserCollectionViewCellDelegate {
    
    var ids : Dictionary<String, Any>!
    var groups : Array<Any> = []
    var users : [[UserInfo]]! = []
    var owners: Array<UserInfo>! = []
    var deal: Deal! = nil
    var deals: Array<Deal>! = []
    var venue : Venue!
    var user : UserInfo!
    var shouldDeleteGroups = true
    var isGroupPage = false
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = FlatBlack()
        self.view.backgroundColor = FlatBlack()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // This is to deal with the case where someone creates a group, then leaves the page. 
        // The group should be deleted unless it's to redeem a deal, or to invite someone, and
        // that's what the shouldDeleteGroups bool is keeping track of
        if (shouldDeleteGroups) {
            for (index, group) in self.groups.enumerated() {
                var dict = group as! Dictionary<String, Any>
                if (dict["users"] == nil) {
                    var group = self.groups[index] as! Dictionary<String, Any>
                    let id = group["id"] as! String
                    Constants.refs.root.child("groups/\(id)").removeValue()
                    Constants.refs.root.child("users/\(self.user.id)/groups/\(id)").removeValue()
                    self.groups[index] = []
                }
            }
            
            // Filter out any empty groups
            self.groups = self.groups.filter { ($0 as AnyObject).count > 0 }
            shouldDeleteGroups = true
        }
        
        Constants.refs.root.removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Get all the groups
        self.getGroups(ids: self.ids as NSDictionary, completionHandler: { (isComplete, groups) in
            if (isComplete) {
                self.groups = groups
                self.collectionView?.reloadData()
                self.users = []
                // When the group's are done loading, get all the group owners
                self.getOwners { (isComplete, owners) in
                    if (isComplete) {
                        self.owners = owners
                        // When the group owners are done loading, get all the users
                        self.getUsers(completionHandler: { (isComplete, users) in
                            if (isComplete) {
                                self.users.append(users as! Array<UserInfo>)
                                self.collectionView?.reloadData()
                            }
                        })
                        
                    }
                }
                
                
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    
    //MARK: UICollectionViewDelegate
    // This is for the group cards specifically, and the cell contains another collection view
    // to show the users
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionViewCell
        
        cell.delegate = self
        cell.redeemButton.isEnabled = false
        
        // Set the index value for the cancel and redeem button, so we know which group is being removed
        cell.redeemButton.layer.setValue(indexPath.row, forKey: "row")
        cell.cancelButton.layer.setValue(indexPath.row, forKey: "row")
        cell.cancelButton.layer.setValue(indexPath.section, forKey: "section")
        cell.cancelButton.addTarget(self, action: #selector(removeGroup(sender:)), for: .touchUpInside)
        
        if (self.deals.count > 0 && (self.deals.count-1) >= indexPath.row) {
            cell.dealLabel.text = self.deals[indexPath.row].shortDescription
            cell.deal = self.deals[indexPath.row]
            if (self.deals[indexPath.row].numberOfPeople != ""){
                cell.numOfPeople = Int(cell.deal!.numberOfPeople)! 
            } else {
                cell.numOfPeople = 1
            }
        }
        
        if (self.owners.count > 0 && self.users.count == 0 && self.owners.count >= (indexPath.row+1)) {
            cell.owner = self.owners[indexPath.row]
        } else if (self.users.count > 0) {
            let foundItems = self.users[indexPath.row].filter { ($0 ).status == "Accepted"}
            if ( (foundItems.count + 1) == cell.numOfPeople && self.owners[indexPath.row].id == self.user.id && self.owners[indexPath.row].id == self.user.id) {
                cell.redeemButton.isEnabled = true
            }
            cell.owner = self.owners[indexPath.row]
            cell.users = self.users[indexPath.row]
        }
        

        cell.usersCollectionView.reloadData()
        
        // Set the group tag so we know which group corresponds to the users
        cell.groupTag = indexPath.row
        cell.user = self.user
        
        return cell
    }
    
    
    
    // This is called when the 'x' button is clicked on the group cards
    // It'll delete the group, and update the back-end accordingly
    func removeGroup(sender: UIButton) {
        let row : Int = (sender.layer.value(forKey: "row")) as! Int
        let section : Int = (sender.layer.value(forKey: "section")) as! Int
        let indexPath = IndexPath(row: row, section: section)
        let group = self.groups[row] as! Dictionary<String, Any>
        let id = group["id"]!
        
        self.collectionView?.performBatchUpdates({
            self.groups.remove(at: row)
            self.collectionView?.deleteItems(at: [indexPath])
        }, completion: { (isComplete) in
            // Only remove the entire group if you're the owner
            if (self.user!.id == self.owners[row].id) {
                Constants.refs.root.child("groups/\(id)").removeValue()
                Constants.refs.root.child("users/\(self.user.id)/groups/\(id)").removeValue()
                for user in self.users[row] {
                    Constants.refs.root.child("users/\(user.id)/groups/\(id)").removeValue()
                }
            // If not, only remove yourself from the group
            } else {
                Constants.refs.root.child("users/\(self.user.id)/groups/\(id)").removeValue()
            }
            
        })
    }
    
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 15 spacing from each side
        return CGSize(width: view.frame.width - 30, height: 180)
    }
    
    
    //MARK: UserCollectionViewCellDelegate
    func invite(index : Int, deal : Deal) {
        self.performSegue(withIdentifier: "FriendsTableVewControllerSegue", sender: [deal, self.groups[index]])
    }
    
    func acceptGroupInvitation(groupIndex : Int) {
        let group = self.groups[groupIndex] as! Dictionary<String, Any>
        let id = group["id"]!
        Constants.refs.root.child("users/\(self.user.id)/groups/\(id)").setValue(true)
        Constants.refs.root.child("groups/\(id)/users/\(self.user.id)").setValue(true)
    }
    
    func declineGroupInvitation(groupIndex : Int) {
        let group = self.groups[groupIndex] as! Dictionary<String, Any>
        let id = group["id"]!
        Constants.refs.root.child("users/\(self.user.id)/groups/\(id)").removeValue()
        Constants.refs.root.child("groups/\(id)/users/\(self.user.id)").removeValue()
    }
    
    func redeem(index: Int) {
        self.performSegue(withIdentifier: "RedemptionViewControllerSegue", sender: index)
        shouldDeleteGroups = false
    }
    
    func getUsers(completionHandler: @escaping (_ isComplete: Bool, _ users:Array<Any>) -> ()) {
        if (self.groups.count > 0) {
            Constants.refs.root.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                self.users = []
                for val in self.groups {
                    var group = val as! Dictionary<String, Any>
                    var userInfos : Array<UserInfo> = []
                   
                    if (group["users"] != nil) {
                        let users = group["users"] as! Dictionary<String, Any>
                        
                        // Loop through all the user ids
                        for (key, val) in users {
                            var user = UserInfo(username: "", name: "", id: "'", age: "'", email: "", gender: "'", profile: "", status: "", groups: [String: Any](), friends: [])
                            
                            // Check if the user value is true or false.
                            // If it is false, the user is still in the invited status
                            if (!(val as! Bool)) {
                                user.status = "Invited"
                            } else {
                            // Else they have accepted
                                user.status = "Accepted"
                            }
                            
                            // Go into firebase and loop through every key for the user path
                            for child in snapshot.childSnapshot(forPath: key).children {
                                let key = (child as! DataSnapshot).key
                                if (key == "name") {
                                    let value = (child as! DataSnapshot).value as! String
                                    user.name = value
                                } else if (key == "id") {
                                    let value = (child as! DataSnapshot).value as! String
                                    user.id = value
                                } else if (key == "profile"){
                                    let value = (child as! DataSnapshot).value as! String
                                    user.profile = value
                                }
                                
                            }
                            userInfos.append(user)
                        }
                        
                    }
                    completionHandler(true, userInfos)
                }
            })
        }
        
    }
    
    func getOwners(completionHandler: @escaping (_ isComplete: Bool, _ owner: Array<UserInfo>) -> ()) {
        let ref = Constants.refs.root.child("users")
        var owners : Array<UserInfo> = []
        ref.observeSingleEvent(of: DataEventType.value, with:{ (snapshot: DataSnapshot) in
            owners = []
            for val in self.groups {
                var group = val as! Dictionary<String, Any>
                if (group["owner"] as! String != "") {
                    var user = UserInfo(username: "", name: "", id: "'", age: "'", email: "", gender: "'", profile: "", status: "", groups: [String: Any](), friends: [])
                    for child in snapshot.childSnapshot(forPath: group["owner"] as! String).children {
                        let key = (child as! DataSnapshot).key
                        if (key == "name") {
                            let value = (child as! DataSnapshot).value as! String
                            user.name = value
                        } else if (key == "id") {
                            let value = (child as! DataSnapshot).value as! String
                            user.id = value
                        } else if (key == "profile"){
                            let value = (child as! DataSnapshot).value as! String
                            user.profile = value
                        }
                        
                    }
                    owners.append(user)
                }
            }
            completionHandler(true, owners)
        })
        
    }
    
    
    // This'll fetch all the informationg relating to the groups of this venue for the user
    func getGroups(ids : NSDictionary, completionHandler: @escaping (_ isComplete: Bool, _ groups:Array<Any>) -> ()){
        var groups : Array<Any> = []
        
        // Query for the groups of this venue
        var ref = Constants.refs.root.child("groups").queryOrdered(byChild: "deal-id").queryEqual(toValue : self.deal!.id)
        
        // If it is the group page, where all groups are shown, query by venue-id instead
        if (isGroupPage) {
            ref = Constants.refs.root.child("groups").queryOrdered(byChild: "venue-id").queryEqual(toValue : self.venue!.id)
        }
        
        ref.observe(DataEventType.value, with:{ (snapshot: DataSnapshot) in
            groups = []
            for (key, _) in ids {
                var dict = [String: Any]()
                var isRedeemed = false
                for child in snapshot.childSnapshot(forPath: key as! String).children {
                    let key = (child as! DataSnapshot).key
               
                    if (key == "deal-id") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["deal-id"] = value
                        self.getDeal(id: value, completionHandler: { (isComplete) in
                        })
                    } else if (key == "id") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["id"] = value
                    } else if (key == "users") {
                        let value = (child as! DataSnapshot).value as! NSDictionary
                        dict["users"] = value
                    } else if (key == "usersStatuses") {
                        let value = (child as! DataSnapshot).value as! Array<Bool>
                        dict["usersStatuses"] = value
                    } else if (key == "created") {
                        let value = (child as! DataSnapshot).value as! Int
                        dict["created"] = value
                    } else if (key == "owner") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["owner"] = value
                    } else if (key == "venue-id") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["venue-id"] = value
                    } else if (key == "redemptions") {
                        isRedeemed = true
                    }
                }
                
                if (dict.count > 0 && !isRedeemed) {
                    groups.append(dict)
                    if (!self.isGroupPage) {
                        groups = groups.sorted { (($0 as! Dictionary<String, Any>)["created"] as! Int)  > (($1 as! Dictionary<String, Any>)["created"] as! Int) }
                    }
                    
                }
            }
            completionHandler(true, groups)
        })
        
    }
    
    func getDeal(id : String, completionHandler: @escaping (_ isComplete: Bool) -> ()) {
        if (id != "") {
            Constants.refs.root.child("deal/\(id)").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let deal = Deal(snapshot: snapshot)
                if (DateHelper.checkDateValidity(validFrom: deal.validFrom as! String, validTo: deal.validTo as! String, recurringFrom: deal.recurringFrom as! String, recurringTo: deal.recurringTo as! String)) {
                    self.deals.append(deal)
                }
                completionHandler(true)
            })
        }
        
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FriendsTableVewControllerSegue") {
            let destVC = segue.destination as? FriendsTableViewController
            var infoArray = sender as! Array<Any>
            destVC?.deal = infoArray[0] as? Deal
            destVC?.group = infoArray[1] as? Dictionary<String, Any>
            shouldDeleteGroups = false
        } else if (segue.identifier == "RedemptionViewControllerSegue") {
            let destVC = segue.destination as? RedemptionViewController
            let index = sender as! Int
            destVC?.group = self.groups[index] as! Dictionary<String, Any>
            destVC?.deal = self.deals[index]
            destVC?.venue = self.venue
            destVC?.owner = self.owners[index]
            destVC?.users = self.users[index]
        }
        
        
    }    
}
