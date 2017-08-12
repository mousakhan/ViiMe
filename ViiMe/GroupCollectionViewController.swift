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
    var deal: Deal!
    var venue : Venue!
    var user : UserInfo!
    var shouldDeleteGroups = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Get all the groups
        self.getGroups(ids: self.ids as NSDictionary, completionHandler: { (isComplete, groups) in
            if (isComplete) {
                self.groups = groups
                self.collectionView?.reloadData()
                self.users = []
                self.getOwners { (isComplete, owners) in
                    if (isComplete) {
                        self.owners = owners
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
        
        self.collectionView?.backgroundColor = FlatBlack()
        self.view.backgroundColor = FlatBlack()
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (shouldDeleteGroups) {
        for (index, group) in self.groups.enumerated() {
            var dict = group as! Dictionary<String, Any>
            if (dict["users"] == nil) {
                var group = self.groups[index] as! Dictionary<String, Any>
                let id = group["id"] as! String
                Database.database().reference().child("groups/\(id)").removeValue()
                Database.database().reference().child("users/\(self.user.id)/groups/\(id)").removeValue()
                self.groups[index] = []
            }
        }
        
        self.groups = self.groups.filter { ($0 as AnyObject).count > 0 }
            shouldDeleteGroups = true
        }
    }
    
    // This is for when you invite someone, and go back to the groups page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    
    // This is for the group cards specifically, and the cell contains another collection view
    // to show the users
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionViewCell
        
        cell.delegate = self
        
        // Set the index value for the cancel button, so we know which group is being removed
        cell.cancelButton.layer.setValue(indexPath.row, forKey: "row")
        cell.cancelButton.layer.setValue(indexPath.section, forKey: "section")
        cell.cancelButton.addTarget(self, action: #selector(removeGroup(sender:)), for: .touchUpInside)
        
        cell.dealLabel.text = self.deal.title
        cell.deal = deal
        
        if (self.owners.count > 0 && self.users.count == 0 ) {
            cell.owner = self.owners[indexPath.row]
            cell.usersCollectionView.reloadData()
        } else if (self.users.count > 0) {
            cell.owner = self.owners[indexPath.row]
            cell.users = self.users[indexPath.row]
        }
    
        cell.usersCollectionView.reloadData()
        cell.numOfPeople = 3
        
        // Set the group tag so we know which group corresponds to the users
        cell.groupTag = indexPath.row
        cell.user = self.user
        
        return cell
    }
    
    
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
            Database.database().reference().child("groups/\(id)").removeValue()
            Database.database().reference().child("users/\(self.user.id)/groups/\(id)").removeValue()
        })
        
        
    
        
        //        self.getUsers(index: i-1) { (isComplete, users) in
        //            if (isComplete) {
        //                for user in users {
        //                    Database.database().reference().child("users/\((user as! UserInfo).id )/groups/\(id)").removeValue()
        //                }
        //                Database.database().reference().child("users/\(self.user.id)/groups/\(id)").removeValue()
        //                //             self.collectionView?.reloadData()
        //            }
        //        }
        //
        
    }
    
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 15 spacing from each side
        return CGSize(width: view.frame.width - 30, height: 180)
    }
    
    func invite(index : Int, deal : Deal) {
        self.performSegue(withIdentifier: "FriendsTableVewControllerSegue", sender: [deal, self.groups[index]])
    }
    
    func acceptGroupInvitation(groupIndex : Int) {
        let group = self.groups[groupIndex] as! Dictionary<String, Any>
        let id = group["id"]!
        Database.database().reference().child("users/\(self.user.id)/groups/\(id)").setValue(true)
        Database.database().reference().child("groups/\(id)/users/\(self.user.id)").setValue(true)
    }
    
    func declineGroupInvitation(groupIndex : Int) {
        let group = self.groups[groupIndex] as! Dictionary<String, Any>
        let id = group["id"]!
        Database.database().reference().child("users/\(self.user.id)/groups/\(id)").removeValue()
        Database.database().reference().child("groups/\(id)/users/\(self.user.id)").removeValue()
    }
    
    
    func getUsers(completionHandler: @escaping (_ isComplete: Bool, _ users:Array<Any>) -> ()) {
        if (self.groups.count > 0) {
            Database.database().reference().child("users").observe(DataEventType.value, with: { (snapshot) in
                self.users = []
                for val in self.groups {
                    var group = val as! Dictionary<String, Any>
                    var userInfos : Array<UserInfo> = []
                    if (group["users"] != nil) {
                        let users = group["users"] as! Dictionary<String, Any>
                        for (key, val) in users {
                            var user = UserInfo(username: "", name: "", id: "'", age: "'", email: "", gender: "'", profile: "", status: "", groups: [String: Any](), friends: [])
                            
                            if (!(val as! Bool)) {
                                user.status = "Invited"
                            }
                            
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
        let ref = Database.database().reference().child("users")
        var owners : Array<UserInfo> = []
        ref.observe(DataEventType.value, with:{ (snapshot: DataSnapshot) in
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
        let ref = Database.database().reference().child("groups").queryOrdered(byChild: "deal").queryEqual(toValue : self.deal!.id)
        ref.observe(DataEventType.value, with:{ (snapshot: DataSnapshot) in
            groups = []
            for (key, _) in ids {
                var dict = [String: Any]()
                for child in snapshot.childSnapshot(forPath: key as! String).children {
                    let key = (child as! DataSnapshot).key
                    
                    if (key == "deal") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["deal"] = value
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
                    }
                }
                
                if (dict.count > 0) {
                    groups.append(dict)
                    groups = groups.sorted { (($0 as! Dictionary<String, Any>)["created"] as! Int)  > (($1 as! Dictionary<String, Any>)["created"] as! Int) }
                }
            }
            completionHandler(true, groups)
        })
        
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
        }
    }
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
