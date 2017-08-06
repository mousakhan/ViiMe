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

class AddFriendTableViewController: UITableViewController, UISearchResultsUpdating {

    @IBOutlet weak var searchBar: UISearchBar!
    
    let reuseIdentifier = "AddFriendCell"
    var friends = [Dictionary<String, Any>]()
    var currUser : UserInfo?
    var ref: DatabaseReference!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currUser)
        
        self.tableView.backgroundColor = FlatBlack()
        ref = Database.database().reference()
      
      
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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
        
        tableView.backgroundColor = FlatBlack()
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? AddFriendTableViewCell
        
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
        

        return cell!
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("HERE)")
        let id = self.friends[indexPath.row]["id?"] as! String
        let path = "users/\(id)/invites"
        ref.child(path).childByAutoId().setValue(currUser?.id)
        
    }
    
    //MARK: UISearchBarDelegate
    
  
    
    //MARK: Helper Functions
    func getSearchResults(query: String) {
        //For why this works: https://stackoverflow.com/questions/38618953/how-to-do-a-simple-search-in-string-in-firebase-database
        
        
        if !query.trimmingCharacters(in: .whitespaces).isEmpty {
           
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
