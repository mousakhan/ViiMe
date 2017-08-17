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

class FriendsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate,  UISearchBarDelegate, UISearchControllerDelegate, AddFriendTableViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var user : User? = Auth.auth().currentUser
    var group : Group? = nil
    var contacts = [Dictionary<String, Any>]()
    var searchController : UISearchController!
    var invites : Array<UserInfo> = []
    var friends : Array<UserInfo> = []
    var ref: DatabaseReference!
    
    // This is for when you invite someone to a deal, if there already is a user in that cell, then we need
    // a way to remove the user if you invite someone else
    var userToDeleteId : String?
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        
        // Check to see if there are any friend invitations
        ref = Constants.refs.root
        // Check to see if there are any friends
        
        initContacts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let friendsRef = ref.child("users/\(user!.uid)/friends")
        friendsRef.observe(DataEventType.value, with: { (snapshot) in
            self.friends = []
            self.invites = []
            let enumerator = snapshot.children
            while let friend = enumerator.nextObject() as? DataSnapshot {
                self.ref.child("users").child(friend.key).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
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
    
    
    //MARK: UITableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.invites.count
        } else if (section == 1) {
            return self.friends.count
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
            cell.nameLabel?.text = self.invites[indexPath.row].username
            cell.backgroundColor = FlatBlack()
            cell.textLabel?.textColor = FlatWhite()
            cell.detailTextLabel?.textColor = FlatWhite()
            
            let profile =  self.invites[indexPath.row].profile
            
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
            
            cell.nameLabel?.text = self.friends[indexPath.row].username
            cell.backgroundColor = FlatBlack()
            cell.textLabel?.textColor = FlatWhite()
            cell.detailTextLabel?.textColor = FlatWhite()
            
            let profile =  self.friends[indexPath.row].profile
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
            
            if (self.group != nil) {
                bgColorView.backgroundColor = .clear
            } else {
                bgColorView.backgroundColor = FlatPurpleDark()
            }
            
             cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
            cell.textLabel?.text = self.contacts[indexPath.row]["name"] as? String
            cell.detailTextLabel?.text = self.contacts[indexPath.row]["number"] as? String
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
            return "Friend Invitations"
        } else if (section == 1) {
            return "My Friends"
        }
        
        return "My Contacts"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = FlatBlackDark()
        let headerTitle = view as? UITableViewHeaderFooterView
        headerTitle?.textLabel?.textColor = FlatWhite()
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            
            let alertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton("Accept", backgroundColor: FlatGreen())   {
                self.ref.child("users/\(self.user!.uid)/friends/\(self.invites[indexPath.row].id)").setValue(true)
                self.ref.child("users/\(self.invites[indexPath.row].id)/friends/\(self.user!.uid)").setValue(true)
                
            }
            
            alertView.addButton("Decline", backgroundColor: FlatRed()) {
                self.ref.child("users/\(self.user!.uid)/friends/\(self.invites[indexPath.row].id)").removeValue()
                
            }
            
            // Don't do anything
            alertView.addButton("Later") {}
            
            
            alertView.showInfo("Accept Invitation", subTitle: "Add \(self.invites[indexPath.row].username) to your friend list")
            
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
        } else if (indexPath.section == 1) {
            if (self.group != nil) {
                let id = self.group?.id ?? ""
                // Check if there is a user to delete, and if so, remove them from backend
                if (self.userToDeleteId != "") {
                    let userId = self.userToDeleteId ?? ""
                    Constants.refs.users.child("\(userId)/groups/\(id)").removeValue()
                    Constants.refs.groups.child("\(id)/users/\(userId)").removeValue()
                    self.userToDeleteId = ""
                }
                
                Constants.refs.groups.child("\(id)/users/\(self.friends[indexPath.row].id)").setValue(false)
                Constants.refs.users.child("\(self.friends[indexPath.row].id)/groups/\(id)").setValue(false)
                self.navigationController?.popViewController(animated: true)
            }
        } else if (indexPath.section == 2) {
            sendSmsClick(recipient: self.contacts[indexPath.row]["number"] as! String, vc: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1) {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.ref.child("users/\(self.user!.uid)/friends/\(self.friends[indexPath.row].id)").removeValue()
            self.ref.child("users/\(self.friends[indexPath.row].id)/friends/\(self.user!.uid)").removeValue()
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
                let alert = UIAlertController(title: "Can't Access Contacts", message: "Please go to Settings -> ViiMe to enable contact permission.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
        let trimmedString = searchText.trimmingCharacters(in: .whitespaces)
        searchBar.text = trimmedString
        
        if searchText == ("") {
            searchBar.text = " "
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController = nil
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
