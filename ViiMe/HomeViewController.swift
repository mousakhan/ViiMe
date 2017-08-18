//
//  HomeViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-17.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit

import UIKit
import ChameleonFramework
import Firebase
import SCLAlertView
import MIBadgeButton_Swift

private let reuseIdentifier = "GroupCategoryCell"
private let headerIdentifier = "GroupHeader"

class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UserCollectionViewCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var groups : [Group] = []
    var invitedGroups : [Group] = []
    var users : [[UserInfo]]! = []
    var owners: Array<UserInfo>! = []
    var deal: Deal! = nil

    var venue : Venue!
    var shouldDeleteGroups = true
    var isGroupPage = false
  
    // This is the contacts list icon with the badge for any new friend request
    let badgeButton : MIBadgeButton = MIBadgeButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    
    @IBOutlet weak var collectionView: UICollectionView!
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = FlatBlack()
        self.collectionView?.delegate = self
        self.collectionView.dataSource = self
        self.view.backgroundColor = FlatBlack()
        

        let origImage = UIImage(named: "contacts");
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        badgeButton.tintColor = FlatWhite()
        
        badgeButton.setImage(tintedImage, for: .normal)
        badgeButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        badgeButton.badgeString = ""
        let barButton : UIBarButtonItem = UIBarButtonItem(customView: badgeButton)
        self.navigationItem.rightBarButtonItem = barButton
        badgeButton.addTarget(self, action: #selector(updateBadge(sender:)), for: .touchUpInside)
        getCurrentUser()
        
        self.getGroups(completionHandler: { (isComplete) in
            if (isComplete) {
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
                for (index, group) in self.invitedGroups.enumerated() {
                    self.getDeal(id: group.dealId, completionHandler: { (isComplete, deal) in
                        if (isComplete) {
                            self.invitedGroups[index].deal = deal
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                    
                    self.getOwner(id: group.ownerId, completionHandler: { (isComplete, owner) in
                        if (isComplete) {
                            self.invitedGroups[index].owner = owner
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                    
                    self.getUsers(ids: group.userIds, completionHandler: { (isComplete, users) in
                        if (isComplete) {
                            self.invitedGroups[index].users = users
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                    
                    self.getVenue(id: group.venueId, completionHandler: { (isComplete, venue) in
                        if (isComplete) {
                            self.invitedGroups[index].venue = venue
                        }
                    })
                }
                
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
                    
                    self.getVenue(id: group.venueId, completionHandler: { (isComplete, venue) in
                        if (isComplete) {
                            self.groups[index].venue = venue
                        }
                    })
                }
            }
        })
        
    }
    
  
 
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // This is to deal with the case where someone creates a group, then leaves the page.
        // The group should be deleted unless it's to redeem a deal, or to invite someone, and
        // that's what the shouldDeleteGroups bool is keeping track of
        if (shouldDeleteGroups) {
            print("Now")
            // Loop through all the groups
            for (_, group) in self.groups.enumerated() {
                print("Group \(group.users.count)")
                // If there are no users, then remove the group from the back-end, which will trigger
                // the group observor and update the array
                if (group.users.count == 0 && self.groups.count > 0) {
                    let id = group.id
                    if (id != "") {
                        Constants.refs.groups.child(id).removeValue()
                        Constants.refs.users.child("\(Constants.getUserId())/groups/\(id)").removeValue()
                    }
                }
            }
            self.collectionView.reloadData()
            shouldDeleteGroups = true
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! GroupCollectionViewHeader
        
        if (indexPath.section == 0) {
            headerView.sectionTitleLabel.text = "GROUP INVITATIONS"
        } else {
            headerView.sectionTitleLabel.text = "ACTIVE GROUPS"
        }
        
        headerView.backgroundColor = .clear
        
        return headerView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // If there are no items in section, then don't show section by
        // setting size to 0
        if (collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) == 0) {
            return CGSize.zero
        }
        
        let headerView = self.view.subviews[0].subviews[0] as! UICollectionReusableView
        let existingSize = headerView.frame.size
        return existingSize
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return self.invitedGroups.count
        }
        return self.groups.count
    }
    
    
    //MARK: UICollectionViewDelegate
    // This is for the group cards specifically, and the cell contains another collection view
    // to show the users
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionViewCell
        
        cell.delegate = self
        cell.redeemButton.isEnabled = false
        cell.groupTag = indexPath.row
        
        // Set the index value for the cancel and redeem button, so we know which group is being removed
        cell.redeemButton.layer.setValue(indexPath.row, forKey: "row")
        cell.cancelButton.layer.setValue(indexPath.row, forKey: "row")
        cell.cancelButton.layer.setValue(indexPath.section, forKey: "section")
        cell.cancelButton.addTarget(self, action: #selector(removeGroup(sender:)), for: .touchUpInside)
        
        
        if (indexPath.section == 1) {
            if (self.groups.count > 0) {
                if (self.groups[indexPath.row].deal != nil) {
                    cell.group = self.groups[indexPath.row]
                    cell.usersCollectionView.reloadData()
                } else {
                    cell.group = nil
                }
                
                if (self.groups[indexPath.row].ownerId != "") {
                    // Check if the user is not the owner of the group
                    if (self.groups[indexPath.row].ownerId != Constants.getUserId()) {
                        // If he is not part of the group, then s/he can accept invitation since they must
                        // have been invited, and adjust button accordingly
                        if (self.groups[indexPath.row].userIds[Constants.getUserId()] != nil) {
                            // Check if user is part of the group already, and adjust button accordingly
                            cell.redeemButton.setTitle("\(self.groups[indexPath.row].owner?.username ?? "") must redeem", for: .normal)
                            cell.redeemButton.backgroundColor = FlatPurple()
                            cell.redeemButton.isEnabled = false
                        }
                    } else {
                        // It is the group owner, so check if they can redeem
                        // by seeing the number of people required for the deal and number of people
                        // in group
                        if let count = self.groups[indexPath.row].deal?.numberOfPeople {
                            
                            var numOfUsers = 0
                            for (_,val) in self.groups[indexPath.row].userIds {
                                if (val) {
                                    numOfUsers = numOfUsers + 1
                                }
                            }
                            
                            if (numOfUsers + 1 == (Int(count) ?? 0)) {
                                cell.redeemButton.isEnabled = true
                                cell.redeemButton.addTarget(cell, action: #selector(cell.redeem(sender:)), for: .touchUpInside)
                            }
                        }
                    }
                } else {
                    cell.group = nil
                }
            }
        } else {
            
            if (self.invitedGroups.count > 0) {
                if (self.invitedGroups[indexPath.row].deal != nil) {
                    cell.group = self.invitedGroups[indexPath.row]
                    cell.usersCollectionView.reloadData()
                } else {
                    cell.group = nil
                }
                
                if (self.invitedGroups[indexPath.row].ownerId != "") {
                    // Check if the user is not the owner of the group
                    if (self.invitedGroups[indexPath.row].ownerId != Constants.getUserId()) {
                        // If he is not part of the group, then s/he can accept invitation since they must
                        // have been invited, and adjust button accordingly
                        if (self.invitedGroups[indexPath.row].userIds[Constants.getUserId()] != nil) {
                            cell.redeemButton.setTitle("Respond to invitation", for: .normal)
                            cell.redeemButton.backgroundColor = FlatGreenDark()
                            cell.redeemButton.isEnabled = true
                            cell.redeemButton.addTarget(cell, action: #selector(cell.respondToInvitation(sender:)), for: .touchUpInside)
                        } else {
                            // Check if user is part of the group already, and adjust button accordingly
                            cell.redeemButton.setTitle("GROUP OWNER MUST REDEEM", for: .normal)
                            cell.redeemButton.backgroundColor = FlatPurple()
                            cell.redeemButton.isEnabled = false
                        }
                    }
                }
                
            } else {
                cell.group = nil
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
        let userId = Constants.getUserId()
        
        
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
                if (Constants.getUserId() == ownerId) {
                    Constants.refs.groups.child("\(id)").removeValue()
                    Constants.refs.users.child("\(Constants.getUserId())/groups/\(id)").removeValue()
                    for user in group.users {
                        Constants.refs.root.child("users/\(user.id)/groups/\(id)").removeValue()
                    }
                    // If not, only remove yourself from the group in back-end
                } else {
                    Constants.refs.users.child("groups/\(id)/users/\(Constants.getUserId())/").removeValue()
                    Constants.refs.users.child("\(Constants.getUserId())/groups/\(id)").removeValue()
                }
            })
            
            alertView.addButton("No thanks", backgroundColor: FlatBlue(), action: {})
            
            if (userId == ownerId) {
                alertView.showInfo("Warning", subTitle: "This will permanently delete the group for all members.\n\n Are you sure you want to continue?")
            } else {
                alertView.showInfo("Warning", subTitle: "This will remove you from the group completely. \n\n Are you sure you want to continue?")
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
    func invite(index : Int, userId : String) {
        self.performSegue(withIdentifier: "FriendsTableVewControllerSegue", sender: [index, userId])
    }
    
    func respondToGroupInvitation(groupIndex: Int) {
        
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Accept", backgroundColor: FlatGreen())   {
            self.acceptGroupInvitation(groupIndex: groupIndex)
        }
        
        alertView.addButton("Decline", backgroundColor: FlatRed()) {
            self.declineGroupInvitation(groupIndex: groupIndex)
        }
        
        
        alertView.addButton("Later") {}
        
        alertView.showInfo("Invitation", subTitle: "Respond to Invitation")
        
    }
    func acceptGroupInvitation(groupIndex : Int) {
        let group = self.invitedGroups[groupIndex]
        let id = group.id
        print(Constants.getUserId())
        Constants.refs.groups.child("\(id)/users/\(Constants.getUserId())").setValue(true)
        Constants.refs.users.child("\(Constants.getUserId())/groups/\(id)").setValue(true)
    }
    
    func declineGroupInvitation(groupIndex : Int) {
        let group = self.invitedGroups[groupIndex]
        let id = group.id
        Constants.refs.root.child("users/\(Constants.getUserId())/groups/\(id)").removeValue()
        Constants.refs.groups.child("\(id)/users/\(Constants.getUserId())").removeValue()
    }
    
    func redeem(index: Int) {
        self.performSegue(withIdentifier: "RedemptionViewControllerSegue", sender: index)
        shouldDeleteGroups = false
    }
    
    func getUsers(ids : Dictionary<String, Bool>, completionHandler: @escaping (_ isComplete: Bool, _ users: [UserInfo]) -> ()) {
        var users : [UserInfo] = []
        
        for (key, val) in ids {
            Constants.refs.users.child(key).observe(.value, with: { (snapshot) in
                var user = UserInfo(snapshot: snapshot)
                // Check if the user value is true or false.
                // If it is false, the user is still in the invited status
                print(val)
                if (!(val )) {
                    user.status = "Invited"
                } else {
                    // Else they have accepted
                    user.status = "Accepted"
                }
                
                users.append(user)
                
                if (users.count == ids.count) {
                    self.collectionView.reloadData()
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
                self.collectionView.reloadData()
                completionHandler(true, user)
                
                
            })
        }
    }
    
    
    // This will get the venue
    func getVenue(id : String, completionHandler: @escaping (_ isComplete: Bool, _ venue: Venue) -> ()) {
        // Make sure there actually is a owner
        if (id != "") {
            // Fetch it from the back-end
            Constants.refs.venues.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                let venue = Venue(snapshot: snapshot)
                completionHandler(true, venue)
            })
        }
    }
    
    // This'll fetch all the information relating to the groups of this venue for the user
    func getGroups(completionHandler: @escaping (_ isComplete: Bool) -> ()){
        // Get the groups from the user's object
        Constants.refs.users.child(Constants.getUserId()).observe(DataEventType.value, with: { (snapshot) in
            let user = UserInfo(snapshot: snapshot)
            self.invitedGroups = []
            self.groups = []
            print(user.groupIds)
            // Loop through group idss
            for (key, val) in user.groupIds {
                var count = 0
                // Fetch it from the back-end
                Constants.refs.groups.child(key).observe(.value, with: { (snapshot) in
                    let group = Group(snapshot: snapshot)
                    // Make sure group isn't already redeemed, not already in array and actually exists
                    if (!group.redeemed && group.id != "") {
                        // If it isn't, add it to one of the arrays depending on whether it is an invitation or not, and if it isn't group page, sort it by creation date
                        // Group you're apart of
                        if (val) {
                            if (self.invitedGroups.contains(where: { $0.id == group.id})) {
                                let index = self.invitedGroups.index(where: {$0.id == group.id})
                                self.invitedGroups.remove(at: index!)
                            }
                            
                            if (!self.groups.contains(where: { $0.id == group.id })) {
                                self.groups.append(group)
                            }
                        } else {
                            if (!self.invitedGroups.contains(where: { $0.id == group.id})) {
                                // Group you were invited to
                                self.invitedGroups.append(group)
                            }
                            
                        }
                    } else {
                        count = count + 1
                    }
                    
                    // Sort the groups by when they were created
                    self.groups = self.groups.sorted { ($0 .created )  > ($1.created ) }
                    self.invitedGroups = self.invitedGroups.sorted { ($0 .created )  > ($1.created ) }
                    
                    // It's complete when the count is equal
                    if (user.groupIds.count == (self.groups.count + self.invitedGroups.count) - count) {
                        self.collectionView.reloadData()
                        completionHandler(true)
                    }
                    
                })
                
            }
        })
        
        
    }
    
    func getDeal(id : String, completionHandler: @escaping (_ isComplete: Bool, _ deal: Deal) -> ()) {
        if (id != "") {
            Constants.refs.root.child("deal/\(id)").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let deal = Deal(snapshot: snapshot)
                self.collectionView.reloadData()
                completionHandler(true, deal)
                
                //TODO: If deal is invalid, then group probably should be removed
            })
        }
        
    }
    
    func getCurrentUser() {
        // Check back end to see if user exists
        let productRef = Constants.refs.users.child("\(Constants.getUserId())")
        productRef.observe(DataEventType.value, with: { (snapshot) in
            let user = UserInfo(snapshot: snapshot)
            
            // Check for invites and update badge accordingly if it is greater than 0
            var count = 0
            for (_, val) in user.friendIds {
                if (!val) {
                    count = count + 1
                }
            }
            if (count > 0) {
                self.badgeButton.badgeString = "\(count)"
            } else {
                self.badgeButton.badgeString = ""
            }
        })
    }
   
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FriendsTableVewControllerSegue") {
            let destVC = segue.destination as? FriendsTableViewController
            let info = sender as? Array ?? []
            // This will be empty if a user goes to this page
            // by clicking the contacts button on the top right
            if (info.count > 0) {
                print(info)
                let index = info[0] as? Int ?? 0
                let userId = info[1] as? String ?? ""
                destVC?.group = self.groups[index]
                destVC?.userToDeleteId =  userId
                shouldDeleteGroups = false
            }
        } else if (segue.identifier == "RedemptionViewControllerSegue") {
            let destVC = segue.destination as? RedemptionViewController
            let index = sender as! Int
            destVC?.group = self.groups[index]
        }
        
        
    }
    
    //MARK: Helpers
    
    // This function will be called when the contacts list bar button item is clicked
    func updateBadge(sender : UIButton) {
        self.performSegue(withIdentifier: "FriendsTableVewControllerSegue", sender: nil)
    }
}

class GroupCollectionViewHeader : UICollectionReusableView {
    @IBOutlet weak var sectionTitleLabel: UILabel!
}

