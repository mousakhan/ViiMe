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
import SCLAlertView

private let reuseIdentifier = "GroupCategoryCell"

class GroupCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserCollectionViewCellDelegate {
    
    var ids : Dictionary<String, Bool>? = nil
    var groups : [Group] = []
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
            // Loop through all the groups
            for (_, group) in self.groups.enumerated() {
                // If there are no users, then remove the group from the back-end, which will trigger
                // the group observor and update the array
                if (group.users.count == 0 && self.groups.count > 0) {
                    let id = group.id
                    if (id != "") {
                        Constants.refs.groups.child(id).removeValue()
                        Constants.refs.users.child("\(self.user.id)/groups/\(id)").removeValue()
                    }
                }
            }
            
            shouldDeleteGroups = true
        }
        
        Constants.refs.root.removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Get all the groups
        self.groups = []
        self.getGroups(ids: ids!, completionHandler: { (isComplete, groups) in
            if (isComplete) {
                for (index, group) in self.groups.enumerated() {
                    self.getDeal(id: group.dealId, completionHandler: { (isComplete, deal) in
                        if (isComplete) {
                            self.groups[index].deal = deal
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                    
                    self.getOwner(id: group.ownerId, completionHandler: { (isComplete, owner) in
                        if (isComplete) {
                            self.groups[index].owner = owner
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                    
                    self.getUsers(ids: group.userIds, completionHandler: { (isComplete, users) in
                        if (isComplete) {
                            self.groups[index].users = users
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
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
        cell.groupTag = indexPath.row
        
        // Set the index value for the cancel and redeem button, so we know which group is being removed
        cell.redeemButton.layer.setValue(indexPath.row, forKey: "row")
        cell.cancelButton.layer.setValue(indexPath.row, forKey: "row")
        cell.cancelButton.layer.setValue(indexPath.section, forKey: "section")
        cell.cancelButton.addTarget(self, action: #selector(removeGroup(sender:)), for: .touchUpInside)
        
        
        if (self.groups.count > 0) {
            if (self.groups[indexPath.row].deal != nil) {
                cell.group = self.groups[indexPath.row]
                cell.usersCollectionView.reloadData()
            } else {
                cell.group = nil
            }
        } else {
            cell.group = nil
        }
        
        
        
        
        if (self.owners.count > 0) {
            // Check if the user is not the owner of the group
            if (self.owners[indexPath.row].id != self.user.id) {
                
                // Check if user is part of the group already, and adjust button accordingly
                if (self.groups[indexPath.row].userIds[self.user.id] != nil) {
                    cell.redeemButton.setTitle("GROUP OWNER MUST REDEEM", for: .normal)
                    cell.redeemButton.backgroundColor = FlatRed()
                    cell.redeemButton.isEnabled = false
                } else {
                    // If he is not part of the group, then s/he can accept invitation since they must
                    // have been invited, and adjust button accordingly
                    cell.redeemButton.setTitle("RESPOND TO INVITATION", for: .normal)
                    cell.redeemButton.backgroundColor = FlatGreenDark()
                    cell.redeemButton.isEnabled = true
                }
            }
        }
        
        
        return cell
    }
    
    
    // This is called when the 'x' button is clicked on the group cards
    // It'll delete the group, and update the back-end accordingly
    func removeGroup(sender: UIButton) {
        let row : Int = (sender.layer.value(forKey: "row")) as! Int
        let section : Int = (sender.layer.value(forKey: "section")) as! Int
        let indexPath = IndexPath(row: row, section: section)
        let group = self.groups[row]
        let id = group.id
        let ownerId =  group.ownerId
        let userId = self.user.id
        
        
        //Setup alert
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
            kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            showCloseButton: false,
            showCircularIcon: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        self.collectionView?.performBatchUpdates({
            
            alertView.addButton("Yes", backgroundColor: FlatRed(), action: {
                
                // Remove users from group and from collectionview
                self.groups.remove(at: row)
                self.collectionView?.deleteItems(at: [indexPath])
                
                // Only remove the entire group from back-end if you're the owner
                if (userId == ownerId) {
                    Constants.refs.groups.child("\(id)").removeValue()
                    Constants.refs.users.child("\(self.user.id)/groups/\(id)").removeValue()
                    for user in group.users {
                        Constants.refs.root.child("users/\(user.id)/groups/\(id)").removeValue()
                    }
                    // If not, only remove yourself from the group in back-end
                } else {
                    Constants.refs.users.child("groups/\(id)/users/\(self.user.id)/").removeValue()
                    Constants.refs.users.child("\(self.user.id)/groups/\(id)").removeValue()
                }
            })
            
            alertView.addButton("No thanks", backgroundColor: FlatBlue(), action: {})
            
            if (userId == ownerId) {
                alertView.showInfo("Warning", subTitle: "This will permanently delete the group for all members.\n Are you sure you want to continue?")
            } else {
                alertView.showInfo("Warning", subTitle: "This will remove you from the group completely. \n Are you sure you want to continue?")
            }
        }, completion: { (isComplete) in
        })
    }
    
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 15 spacing from each side
        return CGSize(width: view.frame.width - 30, height: 180)
    }
    
    
    //MARK: UserCollectionViewCellDelegate
    func invite(index : Int) {
        self.performSegue(withIdentifier: "FriendsTableVewControllerSegue", sender: index)
    }
    
    func acceptGroupInvitation(groupIndex : Int) {
        let group = self.groups[groupIndex]
        let id = group.id
        Constants.refs.root.child("users/\(self.user.id)/groups/\(id)").setValue(true)
        Constants.refs.groups.child("\(id)/users/\(self.user.id)").setValue(true)
    }
    
    func declineGroupInvitation(groupIndex : Int) {
        let group = self.groups[groupIndex]
        let id = group.id
        Constants.refs.root.child("users/\(self.user.id)/groups/\(id)").removeValue()
        Constants.refs.groups.child("\(id)/users/\(self.user.id)").removeValue()
    }
    
    func redeem(index: Int) {
        self.performSegue(withIdentifier: "RedemptionViewControllerSegue", sender: index)
        shouldDeleteGroups = false
    }
    
    func getUsers(ids : Dictionary<String, Bool>, completionHandler: @escaping (_ isComplete: Bool, _ users: [UserInfo]) -> ()) {
        var users : [UserInfo] = []
        
        for (key, val) in ids {
            Constants.refs.users.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                var user = UserInfo(snapshot: snapshot)
                // Check if the user value is true or false.
                // If it is false, the user is still in the invited status
                if (!(val )) {
                    user.status = "Invited"
                } else {
                    // Else they have accepted
                    user.status = "Accepted"
                }
                
                users.append(user)
                
                if (users.count == ids.count) {
                    completionHandler(true, users)
                }
            })
            
        }
        
        
        
    }
    
    // This will loop through all the groups, find the owner user id's and fetch them
    func getOwner(id : String, completionHandler: @escaping (_ isComplete: Bool, _ owner: UserInfo) -> ()) {
        // Make sure there actually is a owner
        if (id != "") {
            // Fetch it from the back-end
            Constants.refs.users.child(id).observeSingleEvent(of: .value, with: { (ownerSnapshot) in
                let user = UserInfo(snapshot: ownerSnapshot)
                completionHandler(true, user)
                
                
            })
        }
    }
    
    
    // This'll fetch all the information relating to the groups of this venue for the user
    func getGroups(ids : Dictionary<String, Bool>, completionHandler: @escaping (_ isComplete: Bool, _ groups:Array<Any>) -> ()){
        
        // Loop through group idss
        for (key, _) in ids {
            var count = 0
            // Fetch it from the back-end
            Constants.refs.groups.child(key).observe(.value, with: { (snapshot) in
                let group = Group(snapshot: snapshot)
                // Make sure group isn't already redeemed, not already in array and actually exists
                if (!group.redeemed && group.id != "" && !self.groups.contains(where: { $0.id == group.id })) {
                    // If it isn't, add it to the array, and if it isn't group page, sort it by creation date
                    self.groups.append(group)
                } else {
                    count = count + 1
                }
                
                // Sort the groups by when they were created
                self.groups = self.groups.sorted { ($0 .created )  > ($1.created ) }
                
                // It's complete when the count is equal
                if (ids.count == self.groups.count - count) {
                    completionHandler(true, self.groups)
                }
                
            })
            
        }
        
        
    }
    
    func getDeal(id : String, completionHandler: @escaping (_ isComplete: Bool, _ deal: Deal) -> ()) {
        if (id != "") {
            Constants.refs.root.child("deal/\(id)").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let deal = Deal(snapshot: snapshot)
                completionHandler(true, deal)
                
                //TODO: If deal is invalid, then group probably should be removed
            })
        }
        
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FriendsTableVewControllerSegue") {
            let destVC = segue.destination as? FriendsTableViewController
            let index = sender as? Int ?? 0
            destVC?.group = self.groups[index]
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
