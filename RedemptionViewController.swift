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

class RedemptionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    private let reusableIdentifier = "cell"
    
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var dealDescriptionLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var deal : Deal!
    var venue : Venue!
    var owner : UserInfo!
    var users : Array<UserInfo>!
    var group : Dictionary<String, Any>!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
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
        
        
        self.dealTitleLabel.text = deal.shortDescription
        
        // Create the message to show
        var subTitle = "Valid from \(DateHelper.parseDate(date: deal.validFrom)) to \(DateHelper.parseDate(date: deal.validTo))"
        
        let recurringTo = DateHelper.parseTime(time: deal.recurringTo)
        let recurringFrom = DateHelper.parseTime(time: deal.recurringFrom)
        
        // If it's a deal that only recurs from certain times, show it
        if (recurringTo != "" && recurringFrom != "") {
            subTitle = subTitle + "\nOnly available from \(recurringFrom) to \(recurringTo) during these dates"
        }
        
        self.dealDescriptionLabel.text = subTitle
        
        collectionView.delegate  = self
        collectionView.dataSource = self
        
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: reusableIdentifier)
        
        self.users = self.users.filter { $0.id != "" }
        
        print(group)
    }
    
    //MARK: UICollectionView Datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath) as! UserCollectionViewCell
        
        cell.profilePicture.image = nil
        cell.isUserInteractionEnabled = false
        
        if (owner != nil && indexPath.row == 0) {
            let name =  owner?.name
            let profile =  owner?.profile
            if (profile != "") {
                let url = URL(string: profile!)
                cell.profilePicture.kf.indicatorType = .activity
                cell.profilePicture.kf.setImage(with: url)
            } else {
                cell.profilePicture.image = UIImage(named: "empty_profile")
            }
            cell.nameLabel.text = name
            cell.profilePicture.contentMode = .scaleToFill
            cell.statusLabel.text = "Group Owner"
        } else if (self.users.count > 0) {
            if ((self.users.count) >= indexPath.row) {
                let index = indexPath.row - 1
                let name =  self.users[index].name
                let profile =  self.users[index].profile
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
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                 BannerHelper.showBanner(title: "Location services must be enabled to redeem deal", type: .danger)
            case .authorizedAlways, .authorizedWhenInUse:
                if (self.venue!.code != self.codeTextField.text) {
                    BannerHelper.showBanner(title: "Incorrect Code Entered", type: .danger)
                } else {
                    BannerHelper.showBanner(title: "Deal Redeemed", type: .success)
                    
                    let id = self.group["id"] as! String
                    
                    // Set value on the group redemption object
                    Constants.refs.root.child("groups/\(id)/redemptions").setValue(["title": deal.title, "short-description": deal.shortDescription, "num-people": deal.numberOfPeople, "valid-from": deal.validFrom, "valid-to": deal.validTo, "recurring-from": deal.recurringFrom, "recurring-to": deal.recurringTo, "num-redemptions": deal.numberOfRedemptions, "active": false, "latitude": self.currentLocation.latitude, "longitude": self.currentLocation.longitude
                        ])
                    
                    
                    // Remove group id from owner
                    Constants.refs.root.child("users/\(owner.id)/groups/\(id)").removeValue()
                    
                    // Remove group id from users
                    for user in users {
                        Constants.refs.root.child("users/\(user.id)/groups/\(id)").removeValue()
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
        print("locations = \(locValue.latitude) \(locValue.longitude)")
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
