//
//  FriendsTableViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-27.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import Contacts
import MessageUI
import Firebase
import SCLAlertView
import DZNEmptyDataSet

class FriendsTableViewController: UITableViewController, UISearchControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var user : User? = Auth.auth().currentUser
    var group : Group? = nil
    var searchController : UISearchController!
    var invites : Array<UserInfo> = []
    var filteredInvites : Array<UserInfo> = []
    var friends : Array<UserInfo> = []
    var filteredFriends : Array<UserInfo> = []
    var ref: DatabaseReference!
    // This is for when you invite someone to a deal, if there already is a user in that cell, then we need
    // a way to remove the user if you invite someone else
    var userToDeleteId : String?
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let friendsRef = Constants.refs.users.child("\(Constants.getUserId())/friends")
        friendsRef.observe(DataEventType.value, with: { (snapshot) in
            self.friends = []
            self.invites = []
            let enumerator = snapshot.children
            while let friend = enumerator.nextObject() as? DataSnapshot {
                Constants.refs.users.child(friend.key).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    let isFriend = friend.value as? Bool
                    let user = UserInfo(snapshot: snapshot)
                    
                    if (!self.friends.contains(where: { $0.id == user.id }) && isFriend!) {
                        self.friends.append(user)
                    }
                    
                    if (!self.invites.contains(where: { $0.id == user.id }) && !isFriend!) {
                        self.invites.append(user)
                    }
                    
                    self.tableView.reloadData()
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
            self.tableView.reloadData()
        })
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    //MARK: UITableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
          
            return self.invites.count
        }
        
            return self.friends.count
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    //MARK: UITableView Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
            
            var invite: UserInfo? = nil
        
                invite = invites[indexPath.row]
            
            
            cell.nameLabel?.text = invite?.username
            cell.backgroundColor = FlatBlack()
            cell.textLabel?.textColor = FlatWhite()
            cell.detailTextLabel?.textColor = FlatWhite()
            
            let profile =  invite?.profile ?? ""
            
            if (profile != "") {
                let url = URL(string: profile)
                cell.profilePicture.kf.indicatorType = .activity
                cell.profilePicture.kf.setImage(with: url)
            } else {
                cell.profilePicture.image = UIImage(named: "empty_profile")
            }
            
            cell.profilePicture.layoutIfNeeded()
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height / 2
            cell.profilePicture.clipsToBounds = true
            cell.profilePicture.layer.borderWidth = 1.0
            cell.profilePicture.layer.borderColor = FlatGray().cgColor
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = FlatPurpleDark()
            cell.selectedBackgroundView = bgColorView
            
            return cell
        }
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
            
            var friend: UserInfo? = nil
        
                friend = friends[indexPath.row]
        
            
            cell.nameLabel?.text = friend?.username
            cell.backgroundColor = FlatBlack()
            cell.textLabel?.textColor = FlatWhite()
            cell.detailTextLabel?.textColor = FlatWhite()
            
            let profile =  friend?.profile ?? ""
            if (profile != "") {
                let url = URL(string: profile)
                cell.profilePicture.kf.indicatorType = .activity
                cell.profilePicture.kf.setImage(with: url)
            } else {
                cell.profilePicture.image = UIImage(named: "empty_profile")
            }
            
            cell.profilePicture.layoutIfNeeded()
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.height / 2
            cell.profilePicture.clipsToBounds = true
            cell.profilePicture.layer.borderWidth = 1.0
            cell.profilePicture.layer.borderColor = FlatGray().cgColor
            
            
            if (self.group != nil) {
                let bgColorView = UIView()
                bgColorView.backgroundColor = FlatPurple()
                cell.selectedBackgroundView = bgColorView
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }
            
            return cell
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if (section == 0) {
            return "Friend Invitations"
        }
        
            return "Friends"
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = FlatBlackDark()
        let headerTitle = view as? UITableViewHeaderFooterView
        headerTitle?.textLabel?.textColor = FlatWhite()
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Remove section  if there aren't any rows in section
        if let numberOfRows = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) {
            if (numberOfRows == 0) {
                return 0
            }
        }
        
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            
            let alertView = SCLAlertView(appearance: appearance)
            
            var invite : UserInfo? = nil
          
                invite = self.invites[indexPath.row]
            
            
            
            alertView.addButton("Accept", backgroundColor: FlatGreen())   {
                
        
                if (Constants.getUserId() != "" && invite?.id != nil && (invite?.id ?? "") != "") {
                    Constants.refs.users.child(Constants.getUserId()).child("friends").child(invite!.id).setValue(true)
                    Constants.refs.users.child(invite!.id).child("friends").child(Constants.getUserId()).setValue(true)
            
                }
                
             

                self.searchBar.text = ""
                self.tableView.reloadData()
            }
            
            alertView.addButton("Decline", backgroundColor: FlatRed()) {
                Constants.refs.users.child("\(Constants.getUserId())/friends/\(invite!.id)").removeValue()
                
            }
            
            // Don't do anything
            alertView.addButton("Maybe Later") {}
            
            self.view.endEditing(true)
            
            alertView.showInfo("Accept Invitation", subTitle: "Add \(invite!.username) to your friend list")
            
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            
        } else if (indexPath.section == 1) {
            var friend : UserInfo? = nil
           
                friend = self.friends[indexPath.row]
            
            
            if (self.group != nil) {
                let dealID = self.group?.deal?.id ?? ""
                let redemptions  = friend?.redemptions ?? [:]
                if (self.group?.deal?.numberOfRedemptions == "0" && redemptions.count > 0) {
                    //  Check if it exists
                    if let _ = redemptions[dealID] {
                        // If it exists then the person has already redeemed
                        let alertView = SCLAlertView()
                        alertView.showError("Error", subTitle: "This user has already redeemed this deal")
                        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                        return
                        
                    }
                }
                
                let id = self.group?.id ?? ""
                // Check if there is a user to delete, and if so, remove them from backend
                if (self.userToDeleteId != "" && self.userToDeleteId != (friend?.id ?? "")) {
                    let userId = self.userToDeleteId ?? ""
                    Constants.refs.users.child("\(userId)/groups/\(id)").removeValue()
                    Constants.refs.groups.child("\(id)/users/\(userId)").removeValue()
                    self.userToDeleteId = ""
                }
                
                
                if (self.userToDeleteId != (friend?.id ?? "")) {
                    Constants.refs.groups.child("\(id)/users/\(friend!.id)").setValue(false)
                    Constants.refs.users.child("\(friend!.id)/groups/\(id)").setValue(false)
                }
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1) {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var friend : UserInfo? = nil
        friend = self.friends[indexPath.row]
        
    
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            Constants.refs.users.child("\(Constants.getUserId())/friends/\(friend!.id)").removeValue()
            Constants.refs.users.child("\(friend!.id)/friends/\(Constants.getUserId())").removeValue()
            self.searchBar.endEditing(true)
            self.searchBar.text = ""
            self.tableView.reloadData()
        }
        
        delete.backgroundColor = FlatRed()
        
        return [delete]
        
    }
  
    
    //MARK: Search Controller
    @IBAction func addFriendButtonClicked(_ sender: Any) {
        // Search Controller setup
        
        
        if (self.searchController == nil) {
            let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFriendTableViewController") as! AddFriendTableViewController
            
            resultsController.searchController = self.searchController
            
            resultsController.userFriends = self.friends
            
            self.searchController = UISearchController(searchResultsController: resultsController)
            self.searchController.searchBar.tintColor = FlatPurpleDark()
            self.searchController.searchBar.barTintColor = FlatPurpleDark()
            self.searchController.searchBar.showsCancelButton = true
            self.searchController.searchResultsUpdater = resultsController as UISearchResultsUpdating
            self.searchController.delegate = self
            self.searchController.hidesNavigationBarDuringPresentation = false
            self.searchController.dimsBackgroundDuringPresentation = true
            self.searchController.searchBar.keyboardAppearance = .dark
            self.searchController.searchBar.returnKeyType = .done
            self.searchController.searchBar.tintColor = FlatPurpleDark()
            self.searchController.searchBar.text = " "
        } else {
            self.searchController.searchBar.text = " "
        }
        
        
        self.present(self.searchController, animated: true) { 
            
        }
        
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if (searchBar.text == "  ") {
                searchBar.text = " "
            } else {
                let trimmedString = searchText.trimmingCharacters(in: .whitespaces)
                searchBar.text = trimmedString
   
                if searchText == "" {
                    searchBar.text = " "
                }
            }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    
            searchBar.endEditing(true)
            searchBar.text = ""
            self.searchController = nil
            tableView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
      
            dismissSearchController()
            self.searchController = nil
            searchBar.endEditing(true)
            tableView.reloadData()
        
        
    }
    //MARK: AddFriendTableViewControllerDelegate
    func dismissSearchController() {
        self.searchController.isActive = false
    }
    
    //MARK: Empty State
    //Add title for empty dataset
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var str = ""
       str = "Add a friend by clicking on the top right button!"
        
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline), NSForegroundColorAttributeName: FlatWhite()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    

  

    
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
