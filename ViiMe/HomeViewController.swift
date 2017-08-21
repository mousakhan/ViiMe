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
import DZNEmptyDataSet
import FirebaseMessaging

private let reuseIdentifier = "GroupCategoryCell"
private let headerIdentifier = "GroupHeader"

class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UserCollectionViewCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var groups : [Group] = []
    var invitedGroups : [Group] = []
    var user : UserInfo? = nil
    // This boolean updates depending on which page you go to
    // If you go to the invite or redeem page, it is set to no, since we don't want the deals to be deleted
    // Otherwise, if you have an empty group, and navigate away from the page, delete it
    var shouldDeleteGroups = true
    // This is to keep track of whether or not it's loading
    var groupsAreLoading = false
    // This is the contacts list icon with the badge for any new friend request
    let friendsBadgeButton : MIBadgeButton = MIBadgeButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    // This is the profile icon with the badge for personal delas
    let rewardsBadgeButton : MIBadgeButton = MIBadgeButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    
    @IBOutlet weak var collectionView: UICollectionView!
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = FlatBlack()
        self.collectionView?.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.emptyDataSetSource = self
        
        self.view.backgroundColor = FlatBlack()
        
        
        let origImage = UIImage(named: "contacts");
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        friendsBadgeButton.tintColor = FlatWhite()
        friendsBadgeButton.setImage(tintedImage, for: .normal)
        friendsBadgeButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        friendsBadgeButton.badgeString = ""
        let barButton : UIBarButtonItem = UIBarButtonItem(customView: friendsBadgeButton)
        self.navigationItem.rightBarButtonItem = barButton
        friendsBadgeButton.addTarget(self, action: #selector(segueToFriendsTableViewController(sender:)), for: .touchUpInside)
        
        
        let profileOrigImage = UIImage(named: "profile");
        let profileTintedImage = profileOrigImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        rewardsBadgeButton.tintColor = FlatWhite()
        rewardsBadgeButton.setImage(profileTintedImage, for: .normal)
        rewardsBadgeButton.badgeString = ""
        let profileBarButton : UIBarButtonItem = UIBarButtonItem(customView: rewardsBadgeButton)
        self.navigationItem.leftBarButtonItem = profileBarButton
        rewardsBadgeButton.addTarget(self, action: #selector(segueToProfileTableViewController(sender:)), for: .touchUpInside)
        
        getCurrentUser()
        
        // This is if the push notification token changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh,
                                               object: nil)
        
    }
    
    func tokenRefreshNotification () {
        if let updatedToken = Messaging.messaging().fcmToken {
            Constants.refs.users.child("\(self.user!.id)/notifications").setValue([updatedToken: true])
        } else {
            print("We don't have an FCM token yet")
        }
        
        
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
                        if (self.groups.contains(where: { $0.id == id})) {
                            let index = self.groups.index(where: {$0.id == id})
                            if (index != nil) {
                                self.groups.remove(at: index!)
                            }
                        }
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
        self.getCurrentUser()
        
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
            headerView.sectionTitleLabel.text = "DEAL INVITATIONS"
        } else {
            headerView.sectionTitleLabel.text = "ACTIVE DEALS"
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
        
        
        if let headerView = self.view.subviews[0].subviews[0] as? UICollectionReusableView {
            let existingSize = headerView.frame.size
            return existingSize
        }
        
        
        return CGSize(width: UIScreen.main.bounds.width, height: 50)
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
        
        
        // Set these and change depending on state
        cell.redeemButton.backgroundColor = FlatPurpleDark()
        cell.redeemButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.redeemButton.addTarget(cell, action: #selector(cell.redeem(sender:)), for: .touchUpInside)
        cell.redeemButton.setTitle("REDEEM", for: .normal)
        cell.redeemButton.isEnabled = false
        
        // The Active Groups Section
        if (indexPath.section == 1) {
            if (self.groups.count > 0) {
                if (self.groups[indexPath.row].deal != nil) {
                    cell.group = self.groups[indexPath.row]
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
                            cell.redeemButton.isEnabled = false
                        }
                    } else {
                        // It is the group owner, so check if they can redeem
                        // by seeing the number of people required for the deal and number of people
                        // in group
                        if let count = self.groups[indexPath.row].deal?.numberOfPeople {
                            
                            var numOfUsersConfirmed = 0
                            var numOfUsersInvited = 0
                            for (_,val) in self.groups[indexPath.row].userIds {
                                if (val) {
                                    numOfUsersConfirmed = numOfUsersConfirmed + 1
                                } else {
                                    numOfUsersInvited = numOfUsersInvited + 1
                                }
                            }
                            
                            if (numOfUsersConfirmed + 1 == (Int(count) ?? 0)) {
                                cell.redeemButton.isEnabled = true
                            } else {
                                
                                let numOfUsersNeeded = abs( (numOfUsersConfirmed + numOfUsersInvited + 1) - (Int(count) ?? 0))
                                // Check if they have the number of people needed. Ifnot, tell them to invite more users
                                // Or if they have invited enough users, tell them they have to wait
                                if (numOfUsersInvited != 0 && numOfUsersNeeded == 0) {
                                    cell.redeemButton.setTitle("Waiting on response", for: .normal)
                                } else  {
                                    cell.redeemButton.setTitle("Invite \(numOfUsersNeeded) more friends", for: .normal)
                                }
                                cell.redeemButton.isEnabled = false
                            }
                        }
                    }
                } else {
                    cell.group = nil
                }
            }
            
            // The invited group section
        } else if (indexPath.section == 0) {
            if (self.invitedGroups.count > 0) {
                if (self.invitedGroups[indexPath.row].deal != nil) {
                    cell.group = self.invitedGroups[indexPath.row]
                    cell.usersCollectionView.reloadData()
                } else {
                    cell.group = nil
                }
                
                if (self.invitedGroups[indexPath.row].ownerId != "") {
                    // Check if the user is not the owner of the group (this should always be the case)
                    if (self.invitedGroups[indexPath.row].ownerId != Constants.getUserId()) {
                        // If he is not part of the group, then s/he can accept invitation since they must
                        // have been invited, and adjust button accordingly
                        if (self.invitedGroups[indexPath.row].userIds[Constants.getUserId()] != nil) {
                            cell.redeemButton.setTitle("Respond to invitation", for: .normal)
                            cell.redeemButton.backgroundColor = FlatGreenDark()
                            cell.redeemButton.isEnabled = true
                            cell.redeemButton.removeTarget(nil, action: nil, for: .allEvents)
                            cell.redeemButton.addTarget(cell, action: #selector(cell.respondToInvitation(sender:)), for: .touchUpInside)
                        } else {
                            // If anything is wrong, just disable the buttone
                            cell.redeemButton.isEnabled = false
                        }
                    }
                }
                
            } else {
                cell.group = nil
            }
            
        }
        
        
        cell.usersCollectionView.reloadData()
        
        
        return cell
    }
    
    
    // This is called when the 'x' button is clicked on the group cards
    // It'll delete the group, and update the back-end accordingly
    func removeGroup(sender: UIButton) {
        let row : Int = (sender.layer.value(forKey: "row")) as! Int
        let section : Int = (sender.layer.value(forKey: "section")) as! Int
        
        var group : Group? = nil
        
        if (section == 0) {
            if (self.invitedGroups.count > 0 && row < (self.invitedGroups.count + 1)) {
                group = self.invitedGroups[row]
            } else {
                showError()
                return
            }
        } else {
            if (self.groups.count > 0 && row < (self.groups.count + 1)) {
                group = self.groups[row]
            } else {
                showError()
                return
            }
        }
        
        let id = group?.id ?? ""
        let ownerId =  group?.ownerId ?? ""
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
                
                // Remove users from group and from collectionview depending on  section
                if (section == 0 && row < (self.invitedGroups.count + 1)) {
                    self.invitedGroups.remove(at: row)
                } else if (section == 1) {
                    self.groups.remove(at: row)
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
                
                // Only remove the entire group from back-end if you're the owner
                if (Constants.getUserId() == ownerId) {
                    Constants.refs.groups.child("\(id)").removeValue()
                    Constants.refs.users.child("\(Constants.getUserId())/groups/\(id)").removeValue()
                    for user in group!.users {
                        Constants.refs.root.child("users/\(user.id)/groups/\(id)").removeValue()
                    }
                    // If not, only remove yourself from the group in back-end
                } else {
                    Constants.refs.groups.child("\(id)/users/\(Constants.getUserId())").removeValue()
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
        self.performSegue(withIdentifier: "FriendsTableViewControllerSegue", sender: [index, userId])
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
        
        
        alertView.addButton("Maybe Later") {}
        
        alertView.showInfo("Invitation", subTitle: "Respond to Invitation")
        
    }
    func acceptGroupInvitation(groupIndex : Int) {
        if (self.invitedGroups.count > 0 && groupIndex < (self.invitedGroups.count + 1))  {
            let group = self.invitedGroups[groupIndex]
            let id = group.id
            Constants.refs.users.child("\(Constants.getUserId())/groups/\(id)").setValue(true)
            Constants.refs.groups.child("\(id)/users/\(Constants.getUserId())").setValue(true)
        } else {
            showError()
        }
    }
    
    func declineGroupInvitation(groupIndex : Int) {
        if (self.invitedGroups.count > 0 && groupIndex < (self.invitedGroups.count + 1))  {
            let group = self.invitedGroups[groupIndex]
            let id = group.id
            Constants.refs.root.child("users/\(Constants.getUserId())/groups/\(id)").removeValue()
            Constants.refs.groups.child("\(id)/users/\(Constants.getUserId())").removeValue()
        } else {
            //Setup alert
            showError()
        }
    }
    
    func redeem(index: Int) {
        self.performSegue(withIdentifier: "RedemptionViewControllerSegue", sender: index)
        shouldDeleteGroups = false
    }
    
    func getUsers(ids : Dictionary<String, Bool>, completionHandler: @escaping (_ isComplete: Bool, _ users: [UserInfo]) -> ()) {
        var users : [UserInfo] = []
        if (ids.count == 0) {
            self.collectionView.reloadData()
            completionHandler(true, [])
        }
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
        // Loop through group idss
        var groupIds : Dictionary<String, Bool> = [:]
        // Check if group ids exist
        if (self.user?.groupIds != nil) {
            groupIds = (self.user?.groupIds)!
            // If there aren't any, then empty out any arrays, refresh and return
            if (groupIds.count == 0){
                self.groups = []
                self.invitedGroups = []
                self.groupsAreLoading = false
                self.collectionView.reloadData()
                self.collectionView.reloadEmptyDataSet()
                completionHandler(false)
            }
            
        }
        
        for (key, val) in groupIds {
            // Fetch it from the back-end
            Constants.refs.groups.child(key).observe(.value, with: { (snapshot) in
                // Have to add it in here since this is what'll be called if there are any changes in the database
                self.groupsAreLoading = true
                var group = Group(snapshot: snapshot)
                
                
                // Check if it already equals  the total
                // If so, clean out the arrays. This is for when user 1 deletes a group
                // and it has to update on user 2's screen
                
                var count = 0
                if (self.user?.groupIds != nil) {
                    count = (self.user?.groupIds.count)!
                }
                
                if (count < (self.groups.count + self.invitedGroups.count)) {
                    self.invitedGroups = []
                    self.groups = []
                    self.collectionView.reloadData()
                    self.collectionView.reloadEmptyDataSet()
                    self.groupsAreLoading = false
                    completionHandler(false)
                }
                
                
                // Make sure group isn't already redeemed, not already in array and actually exists
                if (!group.redeemed && group.id != "") {
                    self.getDeal(id: group.dealId, completionHandler: { (isComplete1, deal) in
                        if (isComplete1) {
                            group.deal = deal
                            self.getOwner(id: group.ownerId, completionHandler: { (isComplete2, owner) in
                                if (isComplete2) {
                                    group.owner = owner
                                    self.getUsers(ids: group.userIds, completionHandler: { (isComplete3, users) in
                                        if (isComplete3) {
                                            group.users = users
                                            self.getVenue(id: group.venueId, completionHandler: { (isComplete4, venue) in
                                                if (isComplete4) {
                                                    group.venue = venue
                                                    // Check if you're apart of the group
                                                    if (val) {
                                                        // If the group exists in the invited groups array, remove it
                                                        if (self.invitedGroups.contains(where: { $0.id == group.id})) {
                                                            let index = self.invitedGroups.index(where: {$0.id == group.id})
                                                            if (index != nil) {
                                                                self.invitedGroups.remove(at: index!)
                                                            }
                                                        }
                                                        
                                                        
                                                        // Check if it already exists, if not, add it
                                                        if (!self.groups.contains(where: { $0.id == group.id })) {
                                                            
                                                            
                                                            self.groups.append(group)
                                                        } else {
                                                            // If it does already exist, update it
                                                            let index = self.groups.index(where: {$0.id == group.id})
                                                            if (index != nil) {
                                                                self.groups[index!] = group
                                                            }
                                                        }
                                                        
                                                        // You aren't part of the group yet, so you're invited
                                                    } else {
                                                        // If you aren't part of the group, join it
                                                        if (!self.invitedGroups.contains(where: { $0.id == group.id})) {
                                                            // Group you were invited to
                                                            self.invitedGroups.append(group)
                                                            // If it does already exist, update it
                                                        } else {
                                                            let index = self.invitedGroups.index(where: {$0.id == group.id})
                                                            if (index != nil) {
                                                                self.invitedGroups[index!] = group
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    // Sort the groups by when they were created
                                                    self.groups = self.groups.sorted { ($0 .created )  > ($1.created ) }
                                                    self.invitedGroups = self.invitedGroups.sorted { ($0 .created )  > ($1.created ) }
                                                    
                                                    // It's complete when the count is equal
                                                    if (count == (self.groups.count + self.invitedGroups.count)) {
                                                        self.groups = self.groups.filter({$0.ownerId == Constants.getUserId() || $0.userIds.keys.contains(Constants.getUserId())})
                                                        self.invitedGroups = self.invitedGroups.filter({$0.ownerId == Constants.getUserId() || $0.userIds.keys.contains(Constants.getUserId())})
                                                        
                                                        self.collectionView.reloadData()
                                                        completionHandler(true)
                                                    }
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                } else {
                    self.groups = self.groups.filter({$0.ownerId == Constants.getUserId() || $0.userIds.keys.contains(Constants.getUserId())})
                    self.invitedGroups = self.invitedGroups.filter({$0.ownerId == Constants.getUserId() || $0.userIds.keys.contains(Constants.getUserId())})
                    
                    self.groupsAreLoading = false
                    self.collectionView.reloadData()
                    self.collectionView.reloadEmptyDataSet()
                    
                }
                
                
                
            })
            
        }
        //        })
        
        
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
        let productRef = Constants.refs.users.child(Constants.getUserId())
        productRef.observe(DataEventType.value, with: { (snapshot) in
            let user = UserInfo(snapshot: snapshot)
            self.user = user
            // Check for invites and update badge accordingly if it is greater than 0
            var count = 0
            for (_, val) in user.friendIds {
                if (!val) {
                    count = count + 1
                }
            }
            if (count > 0) {
                self.friendsBadgeButton.badgeString = "\(count)"
            } else {
                self.friendsBadgeButton.badgeString = ""
            }
            
            if (user.personalDealIds.count > 0) {
                self.rewardsBadgeButton.badgeString = "\(user.personalDealIds.count)"
            } else {
                self.rewardsBadgeButton.badgeString = ""
            }
            
            self.groupsAreLoading = true
            self.getGroups(completionHandler: { (isComplete) in
                if (isComplete) {
                    self.groupsAreLoading = false
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        self.collectionView?.reloadEmptyDataSet()
                    }
                }
            })
        })
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FriendsTableViewControllerSegue") {
            let destVC = segue.destination as? FriendsTableViewController
            let info = sender as? Array ?? []
            // This will be empty if a user goes to this page
            // by clicking the contacts button on the top right
            if (info.count > 0) {
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
        } else if (segue.identifier == "ProfileViewControllerSegue") {
            let destVC = segue.destination as? ProfileViewController
            destVC?.user = self.user
        }
        
        
    }
    
    //MARK: Helpers
    
    func showError() {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
            kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        alertView.showWarning("Something went wrong", subTitle: "The deal might already have been redeemed, or the group owner might have deleted the group.")
        
    }
    // This function will be called when the contacts list bar button item is clicked
    func segueToFriendsTableViewController(sender : UIButton) {
        self.performSegue(withIdentifier: "FriendsTableViewControllerSegue", sender: nil)
    }
    
    // This function will be called when the contacts list bar button item is clicked
    func segueToProfileTableViewController(sender : UIButton) {
        self.performSegue(withIdentifier: "ProfileViewControllerSegue", sender: nil)
    }
    
    //MARK: Empty State
    //Add title for empty dataset
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = ""
        if (groupsAreLoading) {
            str = "Loading your deals"
        } else {
            str = "You aren’t currently part of any deals"
        }
        
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline), NSForegroundColorAttributeName: FlatWhite()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add description/subtitle on empty dataset
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = ""
        if (groupsAreLoading) {
            str = "Please hold on a second!"
        } else {
            str = "Explore the venues, share the experience, enjoy the value!"
        }
        
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),  NSForegroundColorAttributeName: FlatGray()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add  image
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if (groupsAreLoading) {
            return UIImage(named: "wait")
        }
        return UIImage(named: "venue")
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return FlatWhite()
    }
    
    
    
}

class GroupCollectionViewHeader : UICollectionReusableView {
    @IBOutlet weak var sectionTitleLabel: UILabel!
}

