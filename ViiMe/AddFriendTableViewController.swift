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

class AddFriendTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var searchBar: UISearchBar!
    let reuseIdentifier = "AddFriendCell"
    var friends = [Dictionary<String, Any>]()
    
    var ref: DatabaseReference!
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
       
    
        // Search Controller setup
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .done
        self.searchController.searchBar.enablesReturnKeyAutomatically = false
        self.searchController.searchBar.keyboardAppearance = .dark
        
        

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

 
    //MARK: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text!)
         getSearchResults(query: searchController.searchBar.text!)
        self.tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getSearchResults(query: searchController.searchBar.text!)
        self.tableView.reloadData()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.friends.count
    }

    
    //MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    //MARK: Helper Functions
    func getSearchResults(query: String) {
        //For why this works: https://stackoverflow.com/questions/38618953/how-to-do-a-simple-search-in-string-in-firebase-database
       
       
        
        ref.child("users")
            .queryOrdered(byChild: "name")
            .queryStarting(atValue: query)
            .queryEnding(atValue: query+"\u{f8ff}")
            .observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                self.friends = []
                let enumerator = snapshot.children
                while let friend = enumerator.nextObject() as? DataSnapshot {
                    let postDict = friend.value as? NSDictionary
                    var dict = [String: AnyObject]()
                    let name = postDict?["name"]
                    let profile = postDict?["profile"]
                    dict["name"] = name as AnyObject
                    if (profile != nil) {
                        dict["profile"] = profile as AnyObject
                    } else {
                        dict["profile"] = "" as AnyObject
                    }
                    self.friends.append(dict)
                }
                
               
                self.tableView.reloadData()
            
            })
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? FriendTableViewCell
        
        
        if (cell == nil)
        {
            cell = FriendTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)

        }
        
        cell?.nameLabel?.text = self.friends[indexPath.row]["name"] as! String
        cell?.isUserInteractionEnabled = false
        cell?.backgroundColor = FlatBlack()
        cell?.textLabel?.textColor = FlatWhite()
        cell?.detailTextLabel?.textColor = FlatWhite()
        
        let profile =  self.friends[indexPath.row]["profile"] as! String
        
        if (profile != "") {
            let url = URL(string: profile)
            cell?.profilePicture.kf.indicatorType = .activity
            cell?.profilePicture.kf.setImage(with: url)
        }
        print(cell?.profilePicture)
        cell?.profilePicture.layer.cornerRadius = (cell?.profilePicture.frame.width)! / 2
        cell?.profilePicture.layer.borderWidth = 1.0
        cell?.profilePicture.layer.borderColor = FlatGray().cgColor
        cell?.profilePicture.layer.masksToBounds = true
        
        
      
        
        return cell!
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
