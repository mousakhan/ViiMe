//
//  RedemptionViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreLocation
import Firebase
import SCLAlertView

class RedemptionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    private let reusableIdentifier = "cell"
    
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var dealDescriptionLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var venue : Venue? = nil
    var group : Group? = nil
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // Change color of icon button, could probably make this into it's own helper function
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        
        self.dealTitleLabel.text = self.group?.deal?.shortDescription ?? ""
        
        // Create the message to show
        var subTitle = "Valid from \(DateHelper.parseDate(date: self.group?.deal?.validFrom ?? "")) to \(DateHelper.parseDate(date: self.group?.deal?.validTo ?? ""))"
        
        let recurringTo = DateHelper.parseTime(time: self.group?.deal?.recurringTo ?? "")
        let recurringFrom = DateHelper.parseTime(time: self.group?.deal?.recurringFrom ?? "")
        
        // If it's a deal that only recurs from certain times, show it
        if (recurringTo != "" && recurringFrom != "") {
            subTitle = subTitle + "\nOnly available from \(recurringFrom) to \(recurringTo) during these dates"
        }
        
        self.dealDescriptionLabel.text = subTitle
        
        collectionView.delegate  = self
        collectionView.dataSource = self
        
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: reusableIdentifier)
    
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: 80, height: self.collectionView.frame.size.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
 
    //MARK: UICollectionView Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.group?.users.count  ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath) as! UserCollectionViewCell
        
        cell.profilePicture.image = nil
        cell.isUserInteractionEnabled = false
        
        if (self.group?.owner != nil && indexPath.row == 0) {
            let name =  self.group?.owner?.username ?? ""
            let profile =  self.group?.owner?.profile ?? ""
            if (profile != "") {
                let url = URL(string: profile)
                cell.profilePicture.kf.indicatorType = .activity
                cell.profilePicture.kf.setImage(with: url)
            } else {
                cell.profilePicture.image = UIImage(named: "empty_profile")
            }
            cell.nameLabel.text = name
            cell.profilePicture.contentMode = .scaleToFill
            cell.statusLabel.text = "Group Owner"
        } else if ((self.group?.users.count  ?? 0) > 0) {
            if (((self.group?.users.count  ?? 0)) >= indexPath.row) {
                let index = indexPath.row - 1
                let name =  self.group?.users[index].username ?? ""
                let profile =  self.group?.users[index].profile ?? ""
                if (profile != "") {
                    let url = URL(string: profile)
                    cell.profilePicture.kf.indicatorType = .activity
                    cell.profilePicture.kf.setImage(with: url)
                } else {
                    cell.profilePicture.image = UIImage(named: "empty_profile")
                }
                cell.nameLabel.text = name
                cell.profilePicture.contentMode = .scaleToFill
                cell.isUserInteractionEnabled = true
                
            }
        }
        
        
        cell.isUserInteractionEnabled = false
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Specifically to remove keyboard when not interacting with textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    //MARK: IBAction
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func redeemButtonClicked(_ sender: Any) {
        let numberOfRedemptions = self.group?.deal?.numberOfRedemptions ?? ""
        
        // Check if group owner can only redeem once
        // This is just in case they have created multiple groups but can only redeem once
        if (numberOfRedemptions == "1") {
            let redemptions = self.group?.owner?.redemptions ?? [:]
            let id = self.group?.deal?.id ?? ""
            if (redemptions.count > 0) {
                //  Check if it exists
                if let dealExists = redemptions[id] {
                    // If it exists and the value is true, that means the person was a group owner
                    if (dealExists) {
                        let appearance = SCLAlertView.SCLAppearance(
                            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
                            kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                            kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                            showCloseButton: false,
                            showCircularIcon: false
                        )
                        
                        let alertView = SCLAlertView(appearance: appearance)
                        alertView.addButton("OK", backgroundColor: FlatPurple())   {}
                        alertView.showInfo("Error", subTitle: "You can only redeem the deal once as a group owner")
                        return
                    }
                }
            }
            
        }
        
        //Check if users have already redeemed if it's a deal where users can only redeem once
        if (numberOfRedemptions == "0") {
            let id = self.group?.deal?.id ?? ""
            
            let ownerRedemptions = self.group?.owner?.redemptions ?? [:]
            // Make sure you haven't redeemed it
            if (ownerRedemptions.count > 0) {
                //  Check if it exists
                if let dealExists = ownerRedemptions[id] {
                    // If it exists and the value is true, that means the person was a group owner
                    if (dealExists) {
                        let alertView = SCLAlertView()
                        alertView.showError("Error", subTitle: "You can only redeem the deal once")
                        return
                    }
                }
            }
            
            // Then check users
            let users = self.group?.users ?? []
            for user in users {
                if (user.redemptions.count > 0) {
                    if let _ = user.redemptions[id] {
                        // If the value exists, then they've already redeemed the deal once
                        let alertView = SCLAlertView()
                        alertView.showError("Error", subTitle: "\(user.username) has already redeemed the deal once")
                        
                            return
                    }
                }
            }
            
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                 BannerHelper.showBanner(title: "Location services must be enabled to redeem deal", type: .danger)
            case .authorizedAlways, .authorizedWhenInUse:
                if ((self.group?.venue?.code ?? "") != self.codeTextField.text) {
                    BannerHelper.showBanner(title: "Incorrect Code Entered", type: .danger)
                } else {
                    BannerHelper.showBanner(title: "Deal Redeemed", type: .success)
                    
                    let id = self.group?.id ?? ""
                    
                    let title = self.group?.deal?.title ?? ""
                    let shortDescription = self.group?.deal?.shortDescription ?? ""
                    let numberOfPeople = self.group?.deal?.numberOfPeople ?? ""
                    let validFrom = self.group?.deal?.validFrom ?? ""
                    let validTo = self.group?.deal?.validTo ?? ""
                    let recurringFrom = self.group?.deal?.recurringFrom ?? ""
                    let recurringTo = self.group?.deal?.recurringTo ?? ""
                    let numberOfRedemptions = self.group?.deal?.numberOfRedemptions ?? ""
                    
                    // Set value on the group redemption object
                    Constants.refs.groups.child("\(id)/redemptions").setValue(["title": title, "short-description": shortDescription, "num-people": numberOfPeople, "valid-from": validFrom, "valid-to": validTo, "recurring-from": recurringFrom, "recurring-to": recurringTo, "num-redemptions": numberOfRedemptions, "active": false, "latitude": self.currentLocation.latitude, "longitude": self.currentLocation.longitude, "redeemed": ServerValue.timestamp()
                        ])
                    
                    let ownerId = self.group?.owner?.id ?? ""
                    let dealId = self.group?.deal?.id ?? ""
                   
                    // Remove group id from owner
                    Constants.refs.users.child("\(ownerId)/groups/\(id)").removeValue()
                  
                    // If value is true, then they have redeemed as group owner
                    Constants.refs.users.child("\(ownerId)/redemptions").setValue([dealId : true])
                    
                    
                    // Remove group id from users and add deal
                    if let users = self.group?.users {
                        for user in users {
                            Constants.refs.users.child("\(user.id)/groups/\(id)").removeValue()
                            Constants.refs.users.child("\(user.id)/redemptions").updateChildValues([dealId: false])
                            
                        }
                    }
          
                    self.dismiss(animated: true, completion: { 
                        
                    })
                }
            }
        } else {
            BannerHelper.showBanner(title: "Location services must be enabled to redeem deal", type: .danger)
        }
        
        

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLocation = locValue
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
