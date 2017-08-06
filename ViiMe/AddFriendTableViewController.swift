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
    func dismiss()
    func sendSmsClick(recipient: String, vc: UITableViewController)
}


class AddFriendTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let reuseIdentifier = "AddFriendCell"
    var delegate: AddFriendTableViewControllerDelegate?
    
    var friends = [Dictionary<String, Any>]()
    var currUser : UserInfo?
    var ref: DatabaseReference!
    var searchController : UISearchController!
    var contacts = [Dictionary<String, Any>]()
    var filteredContacts =  [Dictionary<String, Any>]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currUser)
        
        self.tableView.backgroundColor = FlatBlack()
        ref = Database.database().reference()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            cell.nameLabel?.text = self.friends[indexPath.row]["name"] as? String
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = FlatBlack()
            cell.textLabel?.textColor = FlatWhite()
            cell.detailTextLabel?.textColor = FlatWhite()
            
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.width / 2
            cell.profilePicture.layer.borderWidth = 1.0
            cell.profilePicture.layer.borderColor = FlatGray().cgColor
            cell.profilePicture.layer.masksToBounds = true
            
            let profile =  self.friends[indexPath.row]["profile"] as! String
            
            if (profile != "") {
                let url = URL(string: profile)
                cell.profilePicture.kf.indicatorType = .activity
                cell.profilePicture.kf.setImage(with: url)
            }
            
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
        
        tableView.backgroundColor = FlatBlack()
       
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {
        
        let id = self.friends[indexPath.row]["id"] as! String
        let path = "users/\(id)/invites"
        let currUserPath = "users/\(currUser?.id)/friends"
        ref.child(path).childByAutoId().setValue(currUser?.id)
        ref.child(currUserPath).childByAutoId().setValue(self.friends[indexPath.row])
       
        } else {
            delegate?.sendSmsClick(recipient: self.filteredContacts[indexPath.row]["number"] as! String, vc: self)
        }
        
         delegate?.dismiss()
    }
    
    // MARK: UITableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if (section == 0) {
            return "Search By Username"
        }
        
        return "My Contacts"
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
        //For why this works: https://stackoverflow.com/questions/38618953/how-to-do-a-simple-search-in-string-in-firebase-database
        
        
        if (query.characters.count > 2) {
            if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                self.filteredContacts = []
                self.contacts.filter({ (dict) -> Bool in
                    let number = dict["number"] as? String
                    if (number?.contains(query))! {
                        self.filteredContacts.append(dict)
                    }
                    return true
                })
                
                print(self.contacts)
                ref.child("users")
                    .queryOrdered(byChild: "name")
                    .queryStarting(atValue: query)
                    .queryEnding(atValue: query+"\u{f8ff}")
                    .observe(.value, with: { (snapshot) -> Void in
                        self.friends = []
                        let enumerator = snapshot.children
                        while let friend = enumerator.nextObject() as? DataSnapshot {
                            let postDict = friend.value as? NSDictionary
                            var dict = [String: AnyObject]()
                            let name = postDict?["name"]
                            let profile = postDict?["profile"]
                            let id = postDict?["id"]
                            
                            dict["name"] = name as AnyObject
                            dict["id"] = id as AnyObject
                            
                            if (profile != nil) {
                                dict["profile"] = profile as AnyObject
                            } else {
                                dict["profile"] = "" as AnyObject
                            }
                            self.friends.append(dict)
                            
                        }
                        
                        
                        self.tableView.reloadData()
                        
                    })
                
                // string contains non-whitespace characters
            } else {
                self.friends = []
                self.filteredContacts = []
            }
        }
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
