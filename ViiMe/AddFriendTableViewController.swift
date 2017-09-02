//
//  AddFriendTableViewController.swift
//
//
//  Created by Mousa Khan on 2017-08-05.
//
//

import UIKit
import Firebase
import ChameleonFramework
import Kingfisher



protocol AddFriendTableViewControllerDelegate {
    func dismissSearchController()
    func sendSmsClick(recipient: String, vc: UITableViewController)
}


class AddFriendTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let reuseIdentifier = "AddFriendCell"
    var delegate: AddFriendTableViewControllerDelegate?
    
    var friends = [Dictionary<String, Any>]()
    var userFriends : Array<UserInfo> = []
    var searchController : UISearchController!
    var contacts = [Dictionary<String, Any>]()
    var filteredContacts =  [Dictionary<String, Any>]()
    
    
    override func viewDidLoad() {
        self.tableView.backgroundColor = FlatBlack()
        // Changing navigation tint color to white, this makes the 'Cancel'
        // button white
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = FlatWhite()
        
    }
    
    //MARK: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate
    func updateSearchResults(for searchController: UISearchController) {
        getSearchResults(query: searchController.searchBar.text!)
        self.tableView.reloadData()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableView Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FriendTableViewCell
            cell.backgroundColor = FlatBlack()
            cell.nameLabel.text = self.friends[indexPath.row]["username"] as? String
            
            let profile =  self.friends[indexPath.row]["profile"] as! String
            
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
            cell.textLabel?.text = self.filteredContacts[indexPath.row]["name"] as? String
            cell.detailTextLabel?.text = self.filteredContacts[indexPath.row]["number"] as? String
            cell.backgroundColor = FlatBlack()
            cell.textLabel?.textColor = FlatWhite()
            cell.detailTextLabel?.textColor = FlatWhite()
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = FlatPurpleDark()
            cell.selectedBackgroundView = bgColorView
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath.section == 0) {
            let username = self.friends[indexPath.row]["username"] as! String
            let id = self.friends[indexPath.row]["id"] as! String
            if (Constants.getUserId() != "") {
                Constants.refs.users.child("\(id)/friends/" + Constants.getUserId()).setValue(false)
                BannerHelper.showBanner(title: "Friend Invitation Sent to \(username)", type: .success)
            }
        } else {
            delegate?.sendSmsClick(recipient: self.filteredContacts[indexPath.row]["number"] as! String, vc: self)
        }
        
        delegate?.dismissSearchController()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = FlatBlackDark()
        let headerTitle = view as? UITableViewHeaderFooterView
        headerTitle?.textLabel?.textColor = FlatWhite()
    }
    
    
    // MARK: UITableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if (section == 0) {
            return "Add by Username"
        }
        
        return "Invite Contacts"
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.friends.count
        }
        return self.filteredContacts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    //MARK: Helper Functions
    func getSearchResults(query: String) {
        if (query.characters.count > 2) {
            
            if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                self.filteredContacts = []
                _ = self.contacts.filter({ (dict) -> Bool in
                    let number = dict["number"] as? String
                    let name = dict["name"] as? String
                    if (number!.contains(query) || (name!.lowercased().contains(query.lowercased()))) {
                        self.filteredContacts.append(dict)
                    }
                    return true
                })
                
     
                //For why this works: https://stackoverflow.com/questions/38618953/how-to-do-a-simple-search-in-string-in-firebase-database
                
                
                
                Constants.refs.users
                    .queryOrdered(byChild: "username")
                    .queryStarting(atValue: query.lowercased())
                    .queryEnding(atValue: query.lowercased() + "\u{f8ff}")
                    .observe(DataEventType.value, with: { (snapshot) -> Void in
                        
                        self.friends = []
                        let enumerator = snapshot.children
                        while let friend = enumerator.nextObject() as? DataSnapshot {
                            
                            let user = UserInfo(snapshot: friend)
                            let id = user.id
                            
                            var dict = [String: String]()
                            
                            print(user.username)
                            
                            dict["name"] = user.name
                            dict["username"] = user.username
                            dict["id"] = user.id
                            
                            if (user.profile != "") {
                                dict["profile"] = user.profile
                            } else {
                                dict["profile"] = ""
                            }
                            
                          
                            if (id != Constants.getUserId() && !self.userFriends.contains(where: { $0.id == id })
                                ) {
                                
                                
                                self.friends.append(dict)
                            }
                            
                        }
                        
                        self.tableView.reloadData()
                        
                    })
            } else {
                self.friends = []
                self.filteredContacts = []
            }
        } else {
            self.friends = []
            self.filteredContacts = []
        }
    }
    
    
    // Remove observors
    deinit {
        Constants.refs.users.removeAllObservers()
    }
    
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
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
