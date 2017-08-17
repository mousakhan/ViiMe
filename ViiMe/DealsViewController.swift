//
//  DealsViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-22.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import SCLAlertView
import Firebase

class DealsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let reuseIdentifier = "UITableViewCell"
    var venue : Venue?
    var deal : Deal? = nil
    var ref: DatabaseReference!
    var groups: Array<Any>?
    var deals : Array<Deal>?
    var userId = ""
    
    @IBOutlet weak var venueInfoView: UIView!
    @IBOutlet weak var aboutThisVenueLabel: UILabel!
    @IBOutlet weak var venueDescriptionLabel: UILabel!
    @IBOutlet weak var venueDeals: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!
    @IBOutlet weak var venueDealsLabel: UILabel!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var websiteIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!
    @IBOutlet weak var venueLogo: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Constants.refs.root
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initDealsView()
        
        // Grab uid in defaults
        if let userId = UserDefaults.standard.object(forKey: "uid") as? String {
            self.userId = userId
        }
 
    }
    
    
    
    //MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venue!.deals.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.backgroundColor = FlatBlackDark()
        cell.textLabel?.text = venue?.deals[indexPath.row].shortDescription
        cell.textLabel?.textColor = FlatWhite()
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = cell.textLabel?.font.withSize(12 )
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = FlatPurpleDark()
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Create custom alert view
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
            kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        // When the 'Create' button is pressed, we write to the backend to create the group
        alertView.addButton("Create", backgroundColor: FlatPurple())    {
            let groupRef = self.ref.child("groups")
            let id = groupRef.childByAutoId()
            
            Constants.refs.groups.child("\(id.key)").setValue(["created": ServerValue.timestamp(), "id": id.key, "deal-id": self.venue!.deals[indexPath.row].id, "owner": self.userId, "venue-id": self.venue!.id])
            Constants.refs.users.child("\(self.userId)/groups/\(id.key)").setValue(true)
            
            self.deal = self.venue!.deals[indexPath.row]
            
            self.performSegue(withIdentifier: "GroupCollectionViewSegue", sender: nil)
        }
        
        alertView.addButton("Cancel", backgroundColor: FlatRed())   {}
        
        
        // Create the message to show
        let title = venue!.deals[indexPath.row].title
        var subTitle = "\(venue!.deals[indexPath.row].shortDescription) \n\n Valid from \(DateHelper.parseDate(date: venue!.deals[indexPath.row].validFrom)) to \(DateHelper.parseDate(date: venue!.deals[indexPath.row].validTo))"
        
        let recurringTo = DateHelper.parseTime(time: venue!.deals[indexPath.row].recurringTo)
        let recurringFrom = DateHelper.parseTime(time: venue!.deals[indexPath.row].recurringFrom)
        
        // If it's a deal that only recurs from certain times, show it
        if (recurringTo != "" && recurringFrom != "") {
            subTitle = subTitle + "\n\nOnly available from \(recurringFrom) to \(recurringTo) during these dates"
        }
        
        alertView.showInfo(title, subTitle: subTitle)
        self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
        
    }
    //MARK: Helper
    func addIcon(name: String, imageView : UIImageView) {
        imageView.image = UIImage(named: name)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = FlatGray()
    }
    
    func initDealsView() {
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        self.navigationItem.title = venue!.name
        
        aboutThisVenueLabel.addBottomBorderWithColor(color: FlatGray(), width: 1)
        
        // Adding tap gesture
        let phoneGesture = UITapGestureRecognizer(target: self, action: #selector(call(_:)))
        phoneLabel.addGestureRecognizer(phoneGesture)
        let webGesture = UITapGestureRecognizer(target: self, action: #selector(openWebsite(_:)))
        websiteLabel.addGestureRecognizer(webGesture)
        let addressGesture = UITapGestureRecognizer(target: self, action: #selector(openAddress(_:)))
        addressLabel.addGestureRecognizer(addressGesture)
        
        let url = URL(string: venue!.logo)
        venueLogo.kf.indicatorType = .activity
        venueLogo.kf.setImage(with: url)
        
        venueDescriptionLabel.text = venue!.description
        addressLabel.text = venue!.address
        websiteLabel.text = venue!.website
        phoneLabel.text = venue!.number
        venueDealsLabel.text = "\(venue!.deals.count) Venue Deals"
        
    
        // Adding icon and changing color
        addIcon(name: "phone", imageView: phoneIcon)
        addIcon(name: "website", imageView: websiteIcon)
        addIcon(name: "address", imageView: addressIcon)
    }
    
    func call(_ sender : UITapGestureRecognizer) {
        let text = (sender.view as! UILabel).text
        let alert = UIAlertController(title: "Call Venue", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            if let phoneCallURL:NSURL = NSURL(string:"tel://\(text!)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL as URL)) {
                    application.openURL(phoneCallURL as URL);
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openWebsite(_ sender: UITapGestureRecognizer) {
        let text = (sender.view as! UILabel).text
        let url = URL(string: text!)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func openAddress(_ sender: UITapGestureRecognizer) {
        let text = (sender.view as! UILabel).text
        let baseUrl: String = "http://maps.apple.com/?q="
        let encodedName = text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let finalUrl = baseUrl + encodedName!
        if let url = URL(string: finalUrl)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    //MARK: IBActions
    @IBAction func groupBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GroupCollectionViewSegue", sender: true)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GroupCollectionViewSegue") {
            let destVC = segue.destination as? GroupCollectionViewController
            destVC?.venue = self.venue!
            if (self.deal != nil) {
                destVC?.deal = self.deal!
            }
            if (sender != nil) {
                destVC?.isGroupPage = true
            } else {
                destVC?.isGroupPage = false
            }
        }
    }
    
    
}
