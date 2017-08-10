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
    var users: Array<UserInfo>!
    var deals: Array<Deal>!
    var venue : Venue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getGroups(ids: self.ids as NSDictionary, completionHandler: { (isComplete, groups) in
            self.groups = []
            if (isComplete) {
                self.groups = groups
                self.collectionView?.reloadData()
            }
        })
        
        self.collectionView?.backgroundColor = FlatBlack()
        self.view.backgroundColor = FlatBlack()
        
        let collectionViewLayout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset =  UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        collectionViewLayout?.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("View appearing")
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionViewCell
        cell.delegate = self
        cell.cancelButton.addTarget(self, action: #selector(removeGroup(sender:)), for: .touchUpInside)
        
        print("Reloading")
        getDeals(index: indexPath.row) { (isComplete, deal) in
            if (isComplete) {
                cell.dealLabel.text = deal.title
                cell.deal = deal
            }
        }
        
        getOwner(index: indexPath.row) { (isComplete, owner) in
            if (isComplete) {
                cell.owner = owner
                cell.usersCollectionView.reloadData()
            }
        }
        
        getUsers(index: indexPath.row) { (isComplete, users) in
            if (isComplete) {
                cell.users = users as! Array<UserInfo>
                cell.usersCollectionView.reloadData()
            }
        }
        
        cell.numOfPeople = 2
        cell.groupTag = indexPath.row
        
        return cell
    }
    
    
    func removeGroup(sender: UICollectionViewCell) {
        //        self.groups.remove(at: index!.row)
        self.collectionView?.reloadData()
    }
    
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 15 spacing from each side
        return CGSize(width: view.frame.width - 30, height: 180)
    }
    
    func invite(index : Int, deal : Deal) {
        self.performSegue(withIdentifier: "FriendsTableVewControllerSegue", sender: [deal, self.groups[index]])
    }
    
    func getUsers(index : Int, completionHandler: @escaping (_ isComplete: Bool, _ users:Array<Any>) -> ()) {
        let group = self.groups[index] as! Dictionary<String, Any>
        // Check if the group has users and if it does, grab them
        if ((group["users"]) != nil) {
            let users = group["users"] as! Array<String>
            var userInfos : Array<UserInfo> = []
            
            for id in users {
                Database.database().reference().child("users/\(id)").observe(DataEventType.value, with: { (userSnapshot) in
                    let user = userSnapshot.value as? NSDictionary
                    let name = user?["name"] ?? ""
                    let id = user?["id"] ?? ""
                    let profile = user?["profile"] ?? ""
                    let userInfo = UserInfo(username: "", name: name as! String, id: id as! String, age: "", email: "", gender: "", profile: profile as! String, groups: [String: Any](), friends: [])
                    userInfos.append(userInfo)
                    completionHandler(true, userInfos)
                })
            }
        }
    }
    
    func getOwner(index : Int, completionHandler: @escaping (_ isComplete: Bool, _ owner: UserInfo) -> ()) {
        let group = self.groups[index] as! Dictionary<String, Any>
        let ownerId = group["owner"] as! String
        Database.database().reference().child("users/\(ownerId)").observe(DataEventType.value, with: { (userSnapshot) in
            let user = userSnapshot.value as? NSDictionary
            let name = user?["name"] ?? ""
            let id = user?["id"] ?? ""
            let profile = user?["profile"] ?? ""
            let userInfo = UserInfo(username: "", name: name as! String, id: id as! String, age: "", email: "", gender: "", profile: profile as! String, groups: [String: Any](), friends: [])
            completionHandler(true, userInfo)
        })
        
    }
    
    func getDeals(index : Int, completionHandler: @escaping (_ isComplete: Bool, _ deal: Deal) -> ()) {
        let group = self.groups[index] as! Dictionary<String, Any>
        let id = group["deal"] as! String
        
        Database.database().reference().child("deal/\(id)").observe(DataEventType.value, with: { (dealSnapshot) in
            let deal = dealSnapshot.value as? NSDictionary
            //TODO: Change this to 'title'
            let title = deal?["name"] ?? ""
            let numberOfPeople = deal?["numberOfPeople"] ?? ""
            let id = deal?["id"] ?? ""
            
            let dealInfo = Deal(title: title as! String, shortDescription: "", longDescription: "", id: id as! String, numberOfPeople: numberOfPeople as! String, validFrom: "", validTo: "", recurringFrom: "", recurringTo: "")
            
            completionHandler(true, dealInfo)
        })
        
    }
    
    // This'll fetch all the informationg relating to the groups of this venue for the user
    func getGroups(ids : NSDictionary, completionHandler: @escaping (_ isComplete: Bool, _ groups:Array<Any>) -> ()){
        var groups : Array<Any> = []
        // Query for the groups of this venue
        let ref = Database.database().reference().child("groups").queryOrdered(byChild: "venue").queryEqual(toValue : self.venue!.id)
        ref.observe(DataEventType.value, with:{ (snapshot: DataSnapshot) in
            print("Heeereee")
            groups = []
            let enumerator = snapshot.children
            while let group = enumerator.nextObject() as? DataSnapshot {
                let value = group.value as? NSDictionary
                let id = value?["id"] ?? ""
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
                dict["id"] = id
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
        if (segue.identifier == "FriendsTableVewControllerSegue") {
            let destVC = segue.destination as? FriendsTableViewController
            var infoArray = sender as! Array<Any>
            destVC?.deal = infoArray[0] as? Deal
            destVC?.group = infoArray[1] as? Dictionary<String, Any>
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
