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

class FriendsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate,  UISearchBarDelegate, UISearchControllerDelegate, AddFriendTableViewControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var user : User? = Auth.auth().currentUser
    var group : Group? = nil
    var contacts = [Dictionary<String, Any>]()
    var filteredContacts  = [Dictionary<String, Any>]()
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
        searchBar.delegate = self
        searchBar.keyboardAppearance = .dark
        initContacts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let friendsRef = Constants.refs.users.child("\(user!.uid)/friends")
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Constants.refs.root.removeAllObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredFriends = friends.filter({( friend : UserInfo) -> Bool in
            return friend.name.lowercased().contains(searchText.lowercased())
        })
        
        filteredInvites = invites.filter({( friend : UserInfo) -> Bool in
            return friend.name.lowercased().contains(searchText.lowercased())
        })
        
        filteredContacts = []
        _ = self.contacts.filter({ (dict) -> Bool in
            let number = dict["number"] as? String
            let name = dict["name"] as? String
            if (number!.contains(searchText.lowercased()) || (name!.lowercased().contains(searchText.lowercased()))) {
                self.filteredContacts.append(dict)
            }
            return true
        })
        
        print(filteredContacts)
        tableView.reloadData()
    }
    
    
    
    //MARK: UITableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if (isSearchActive()) {
                return self.filteredInvites.count
            }
            return self.invites.count
        } else if (section == 1) {
            if (isSearchActive()) {
                return self.filteredFriends.count
            }
            return self.friends.count
        }
        
        if (isSearchActive()) {
            return self.filteredContacts.count
        }
        
        return self.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    //MARK: UITableView Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
            
            var invite: UserInfo? = nil
            if isSearchActive(){
                invite = filteredInvites[indexPath.row]
            } else {
                invite = invites[indexPath.row]
            }
            
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
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
            
            var friend: UserInfo? = nil
            if isSearchActive(){
                friend = filteredFriends[indexPath.row]
            } else {
                friend = friends[indexPath.row]
            }
            
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
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = FlatPurpleDark()
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
            
            
            var contact: Dictionary<String, Any>? = nil
            if isSearchActive(){
                contact = filteredContacts[indexPath.row]
            } else {
                contact = contacts[indexPath.row]
            }
            
            cell.textLabel?.text = contact?["name"] as? String
            cell.detailTextLabel?.text = contact?["number"] as? String
            cell.backgroundColor = FlatBlack()
            cell.textLabel?.textColor = FlatWhite()
            cell.detailTextLabel?.textColor = FlatWhite()
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = FlatPurpleDark()
            cell.selectedBackgroundView = bgColorView
            
            return cell
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if (section == 0) {
            return "Invitations"
        } else if (section == 1) {
            return "Friends"
        }
        
        return "Contacts"
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
            if (isSearchActive()) {
                invite = self.filteredInvites[indexPath.row]
            } else {
                invite = self.invites[indexPath.row]
            }
            
            
            alertView.addButton("Accept", backgroundColor: FlatGreen())   {
                Constants.refs.users.child("\(Constants.getUserId())/friends/\(invite!.id)").setValue(true)
                Constants.refs.users.child("\(invite!.id)/friends/\(Constants.getUserId())").setValue(true)
                self.filteredInvites = []
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
            if (isSearchActive()) {
                friend = self.filteredFriends[indexPath.row]
            } else {
                friend = self.friends[indexPath.row]
            }
            
            if (self.group != nil) {
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
        } else if (indexPath.section == 2) {
            var contact : Dictionary<String, Any>? = nil
            if (isSearchActive()) {
                contact = self.filteredContacts[indexPath.row]
            } else {
                contact = self.contacts[indexPath.row]
            }
            
            sendSmsClick(recipient: contact!["number"] as! String, vc: self)
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
        if (isSearchActive()) {
            friend = self.filteredFriends[indexPath.row]
        } else {
            friend = self.friends[indexPath.row]
        }
        
        
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
    //MARK: Helper Functions
    
    func initContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            guard granted else {
                return
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            request.sortOrder = CNContactSortOrder.givenName
            
            
            do {
                try store.enumerateContacts(with: request){
                    (contact, cursor) -> Void in
                    
                    for phoneNumber in contact.phoneNumbers {
                        if let number = phoneNumber.value as? CNPhoneNumber {
                            if (number.stringValue != "" && contact.givenName != "") {
                                self.contacts.append(["name": contact.givenName + " " + contact.familyName, "number": number.stringValue])
                            }
                        }
                        
                    }
                    
                }
            } catch let error {
                NSLog("Fetch contact error: \(error)")
            }
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    //MARK: MFMessageComposeViewControllerDelegate
    func sendSmsClick(recipient: String, vc: UITableViewController) {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Download ViiMe to join me on this exclusive offer! https://itunes.apple.com/ca/app/viime/id1144678737?mt=8";
        messageVC.recipients = [recipient]
        messageVC.messageComposeDelegate = self;
        vc.present(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            controller.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
    
    func isSearchActive() -> Bool {
        return  self.searchBar.text != ""
    }
    
    //MARK: Search Controller
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            self.searchController.searchResultsController?.view.isHidden = false
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchResultsController?.view.isHidden = false
    }
    
    @IBAction func addFriendButtonClicked(_ sender: Any) {
        // Search Controller setup
        
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFriendTableViewController") as! AddFriendTableViewController
        
        resultsController.delegate = self
        
        resultsController.searchController = self.searchController
        
        resultsController.userFriends = self.friends
        resultsController.contacts = self.contacts
        
        self.searchController = UISearchController(searchResultsController: resultsController)
        
        self.searchController.searchBar.tintColor = FlatPurpleDark()
        self.searchController.searchBar.barTintColor = FlatPurpleDark()
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchResultsUpdater = resultsController as UISearchResultsUpdating
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .done
        self.searchController.searchBar.enablesReturnKeyAutomatically = false
        self.searchController.searchBar.keyboardAppearance = .dark
        self.searchController.searchBar.tintColor = FlatPurpleDark()
        self.searchController.searchBar.text = " "
        
        
        present(self.searchController, animated: true) {
            
        }
        
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchBar == self.searchBar) {
            filteredFriends = friends.filter({( friend : UserInfo) -> Bool in
                return friend.username.lowercased().contains(searchBar.text!.lowercased())
            })
            
            filteredInvites = invites.filter({( friend : UserInfo) -> Bool in
                return friend.username.lowercased().contains(searchBar.text!.lowercased())
            })
            
            filteredContacts = []
            _ = self.contacts.filter({ (dict) -> Bool in
                let number = dict["number"] as? String
                let name = dict["name"] as? String
                if (number!.contains(searchBar.text!.lowercased()) || (name!.lowercased().contains(searchBar.text!.lowercased()))) {
                    self.filteredContacts.append(dict)
                }
                return true
            })
            self.tableView.reloadData()
        } else {
            let trimmedString = searchText.trimmingCharacters(in: .whitespaces)
            searchBar.text = trimmedString
            
            if searchText == ("") {
                searchBar.text = " "
            }
            
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar == self.searchBar) {
            searchBar.endEditing(true)
            searchBar.text = ""
            tableView.reloadData()
        } else {
            self.searchController = nil
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        tableView.reloadData()
        
    }
    //MARK: AddFriendTableViewControllerDelegate
    func dismissSearchController() {
        self.searchController.isActive = false
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
