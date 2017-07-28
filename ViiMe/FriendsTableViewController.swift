//
//  FriendsTableViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-27.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework


class FriendsTableViewController: UITableViewController {
  
    let screenSize = UIScreen.main.bounds
    var friends = ["Sunny", "Arian"]
    
    
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
 
    
    @IBAction func friendsButtonClicked(_ sender: Any) {
       
        self.tableView.reloadData()
    }
    
    @IBAction func contactButtonClicked(_ sender: Any) {
        
    }
  
    @IBOutlet weak var searchBar: UISearchBar!
    
    func changeSearchBarIcon() {
        let width = 20
        let height = 20
        
        let topView: UIView = searchBar.subviews[0] as UIView
        var textField:UITextField!
        for subView in topView.subviews {
            if subView is UITextField {
                textField = subView as! UITextField
                break
            }
        }
        
        if ((textField) != nil) {
            let leftview = textField.leftView as! UIImageView
            let magnifyimage = leftview.image
            let imageView  = UIImageView(frame: CGRect(x: Int(searchBar.frame.origin.x) + 15 , y:  10, width: width, height: height ) )
            imageView.image = magnifyimage
            textField.leftView = UIView(frame: CGRect(x: 0 , y: 0, width: Int(width), height: height) )
            textField.leftViewMode = .always
            textField.superview?.addSubview(imageView)
            textField.superview?.layer.borderColor = FlatGray().cgColor
            textField.superview?.layer.borderWidth = 0.5
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


       
        
        
        
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        self.navigationItem.backBarButtonItem?.title = ""
        
     
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
   
 
   
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return self.friends.count
        
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)

        cell.backgroundColor = FlatBlack()
        cell.textLabel?.textColor = FlatWhite()
        cell.detailTextLabel?.textColor = FlatWhite()
      
         
        cell.textLabel?.text = self.friends[indexPath.row]
        cell.detailTextLabel?.text = ""
            
        
        
        // Configure the cell...

        return cell
    }
 

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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
