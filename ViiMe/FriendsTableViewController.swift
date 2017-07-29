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

class FriendsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
  
    @IBOutlet weak var searchBar: UISearchBar!
    
    var friends = ["Sunny", "Arian"]
    var contacts = [Dictionary<String, Any>]()
 
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        initContacts()
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
            return self.friends.count
        }
        return self.contacts.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    //MARK: UITableView Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)

        cell.backgroundColor = FlatBlack()
        cell.textLabel?.textColor = FlatWhite()
        cell.detailTextLabel?.textColor = FlatWhite()
      
        if (indexPath.section == 0) {
            cell.textLabel?.text = self.friends[indexPath.row]
            cell.detailTextLabel?.text = ""
            cell.isUserInteractionEnabled = false
        } else if (indexPath.section == 1) {
            //TODO: Customize cell to show "INVITE" button on right.
            cell.textLabel?.text = self.contacts[indexPath.row]["name"] as? String
            cell.detailTextLabel?.text = self.contacts[indexPath.row]["number"] as? String
        }
        
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            sendSmsClick(recipient: self.contacts[indexPath.row]["number"] as! String)
        }
    }


    //MARK: Helper Functions
    
    func initContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            guard granted else {
                let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
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
                        if let number = phoneNumber.value as? CNPhoneNumber,
                            let label = phoneNumber.label {
                            let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
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
    

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if (section == 0) {
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
    //MARK: MFMessageComposeViewControllerDelegate
    func sendSmsClick(recipient: String) {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Download ViiMe to join me on this exclusive offer! https://itunes.apple.com/ca/app/viime/id1144678737?mt=8";
        messageVC.recipients = [recipient]
        messageVC.messageComposeDelegate = self;
        self.present(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
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
