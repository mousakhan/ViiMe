//
//  ProfileViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import FBSDKLoginKit
import FirebaseStorage
import SCLAlertView
import CoreLocation
import DZNEmptyDataSet
import MessageUI

class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var rewardsTableView: UITableView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var user: UserInfo!
    var imagePicker: UIImagePickerController!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = FlatBlack()
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        
        //Profile Image Setup
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2.0
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = FlatGray().cgColor
        profilePicture.layer.masksToBounds = true
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        profilePicture.addGestureRecognizer(photoTapGesture)
        
        
        self.usernameTextField.text = user.username
        self.nameTextField.text = user.name
        self.emailTextField.text = user.email
        self.ageTextField.text = user.age

        if (user.profile != "") {
            let url = URL(string: user.profile)
            self.profilePicture.kf.indicatorType = .activity
            self.profilePicture.kf.setImage(with: url)
        } else {
            self.profilePicture.image = UIImage(named: "empty_profile")
        }
        
        // Textfield setup
        setupTextField(textfield: usernameTextField)
        setupTextField(textfield: nameTextField)
        setupTextField(textfield: emailTextField)
        setupTextField(textfield: ageTextField)

        
        // Tableview set up
        setupTableview(tableView: rewardsTableView)
        
        
        
        self.getPersonalDeals()
        
        // Keyboard Set up
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard(sender:)))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLocation = locValue
    }
    
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.user.personalDeals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.backgroundColor = FlatBlack()
        
        cell.backgroundColor = FlatBlackDark()
        
        cell.textLabel?.textColor = FlatWhite()
        cell.textLabel?.font = cell.textLabel?.font.withSize(12)
        
        cell.detailTextLabel?.textColor = FlatWhiteDark()
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = cell.textLabel?.font.withSize(10)
        
        
        
        if (self.user.personalDeals.count > 0) {
            cell.textLabel?.text = self.user.personalDeals[indexPath.row].title
            cell.detailTextLabel?.text = self.user.personalDeals[indexPath.row].shortDescription
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = FlatPurpleDark()
        cell.selectedBackgroundView = bgColorView
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.rewardsTableView) {
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
                kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                showCloseButton: false,
                showCircularIcon: false
            )
            
            
            let alertView = SCLAlertView(appearance: appearance)
            
            let redemptionTextField = alertView.addTextField("Enter redemption code")
            redemptionTextField.keyboardAppearance = .dark
            
            alertView.addButton("Redeem", backgroundColor: FlatPurple(), action: {
                if (CLLocationManager.locationServicesEnabled() && redemptionTextField.text == self.user.personalDeals[indexPath.row].venue?.code) {
                    switch(CLLocationManager.authorizationStatus()) {
                    case .notDetermined, .restricted, .denied:
                        BannerHelper.showBanner(title: "Location services must be enabled to redeem deal", type: .danger)
                    case .authorizedAlways, .authorizedWhenInUse:
                        let deal = self.user.personalDeals[indexPath.row]
                        // Set value on the group redemption object
                        Constants.refs.root.child("groups").childByAutoId().child("redemptions").setValue(["title": deal.title, "short-description": deal.shortDescription, "num-people": deal.numberOfPeople, "valid-from": deal.validFrom, "valid-to": deal.validTo, "recurring-from": deal.recurringFrom, "recurring-to": deal.recurringTo, "num-redemptions": deal.numberOfRedemptions, "active": false, "latitude": self.currentLocation.latitude, "longitude": self.currentLocation.longitude, "users": [Constants.getUserId() : true, "redeemed": ServerValue.timestamp()]
                            ])
                        
                        Constants.refs.root.child("users/\(Constants.getUserId())/personal-deals/\(self.user.personalDeals[indexPath.row].id)").removeValue()
                        
                        self.user.personalDeals.remove(at: indexPath.row)
                        self.rewardsTableView.reloadData()
                        BannerHelper.showBanner(title: "Redemption successful", type: .success)
                    }
                } else {
                    BannerHelper.showBanner(title: "Incorrect redemption code entered", type: .danger)
                }
            })
            
            alertView.addButton("Cancel", backgroundColor: FlatRed(), action: {
                
            })
            
            alertView.showInfo("Redeem Personal Deal", subTitle: "Please pass it to the merchant to enter the redemption code")
            
        }
        
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
    
    //MARK: Image Picker
    func takePhoto() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
            kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Camera", backgroundColor: FlatPurple(), action: {
            self.openCamera()
        })
        
        alertView.addButton("Photos", backgroundColor: FlatBlueDark(), action: {
            self.openGallary()
        })
        
        
        alertView.addButton("Maybe Later",  action: {
        })
        
        
        alertView.showInfo("Choose Image", subTitle: "Change your profile picture by either taking a photo, or selecting one from your photo roll!")
        
     
    }
    
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            
            let alert  = SCLAlertView()
            alert.showError("Error", subTitle: "You don't have a camera")
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        var tmpImage : UIImage? = nil
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            tmpImage = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            tmpImage = image
        }
        
        if (tmpImage != nil) {
        
            let storageRef = Storage.storage().reference().child("profile/ " + Constants.getUserId()
                + ".png")
            
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    print("Deleted!")
                    // File deleted successfully
                }
            }
            
            
            if let uploadData = UIImagePNGRepresentation(tmpImage!) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    Constants.refs.users.child(Constants.getUserId()).updateChildValues(["profile": metadata?.downloadURL()?.absoluteString ?? ""])
             
                    let downloadURL = metadata?.downloadURL()?.absoluteString ?? ""
                    print("HERE")
                    print(downloadURL)
                    
                    if (downloadURL != "") {
                        let url = URL(string: downloadURL)
                        self.profilePicture.kf.indicatorType = .activity
                        self.profilePicture.kf.setImage(with: url)
                    } else {
                        self.profilePicture.image = nil
                        self.profilePicture.image = UIImage(named: "empty_profile")
                    }
                    
                })
            }
            
        }
        
    }
    
    
    // MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === self.ageTextField) {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            
            // Set max date`
            var components = DateComponents()
            components.year = -16
            let maxDate = Calendar.current.date(byAdding: components, to: Date())
            datePicker.maximumDate = maxDate
            
            
            if (self.ageTextField.text != nil) {
                datePicker.setDate(getDateFromString(date: self.ageTextField.text!), animated: true)
            }
            datePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == nameTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            ageTextField.becomeFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let name =  nameTextField.text ?? ""
        let age = ageTextField.text ?? ""
        let email = emailTextField.text ?? ""
        
        if (Constants.getUserId() != "") {
            Constants.refs.users.child("\(Constants.getUserId())/name").setValue(name)
            Constants.refs.users.child("\(Constants.getUserId())/age").setValue(age)
            Constants.refs.users.child("\(Constants.getUserId())/email").setValue(email)
        }
    
    }
    
    //MARK: Helper Functions
    func hideKeyboard(sender: AnyObject) {
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func datePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        ageTextField.text = formatter.string(from: sender.date)
    }
    
    
    func setupTextField(textfield: UITextField) {
        textfield.backgroundColor = FlatBlackDark()
        textfield.layer.borderColor = FlatGrayDark().cgColor
        textfield.layer.borderWidth = 0.5
        textfield.layer.masksToBounds = true
        textfield.delegate = self
    }
    
    func setupTableview(tableView: UITableView) {
        tableView.backgroundColor = FlatBlackDark()
        tableView.separatorColor = FlatGray()
        tableView.layer.borderColor = FlatGrayDark().cgColor
        tableView.layer.borderWidth = 0.5
        tableView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    
    func getDateFromString(date: String)-> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if date == "" {
            let date = Date()
            return formatter.date(from: formatter.string(from: date))!
        }
        return formatter.date(from: date)!
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    
    func getPersonalDeals() {
        for (key, _) in self.user.personalDealIds {
            Constants.refs.deals.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                var deal = Deal(snapshot: snapshot)
                self.getVenue(id: deal.venueId, completionHandler: { (isComplete, venue) in
                    if (isComplete) {
                        deal.venue = venue
                        self.user.personalDeals.append(deal)
                        if (self.user.personalDeals.count == self.user.personalDealIds.count) {
                            self.rewardsTableView.reloadData()
                        }
                    }
                })
                
            })
            
        }
    }
    
    
    func getVenue(id : String, completionHandler: @escaping (_ isComplete: Bool, _ venue: Venue) -> ()) {
        if (id != "") {
            Constants.refs.venues.child("\(id)").observe(DataEventType.value, with: { (snapshot) in
                let venue = Venue(snapshot: snapshot)
                completionHandler(true, venue)
            })
        }
        
    }
    
    //MARK: IBActions
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        
        if ((FBSDKAccessToken.current()) != nil) {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        let token = Messaging.messaging().fcmToken
        if (token != nil) {
            Constants.refs.root.child("users/\(Constants.getUserId())/notifications/\(token!)").removeValue()
        }
        
        
        let presentingViewController = self.presentingViewController
        self.dismiss(animated: false, completion: {
            presentingViewController!.dismiss(animated: true, completion: {})
        })
        
    }
    
    @IBAction func dismissProfilePage(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: DZNEmptyDataSet Delegate & Datasource
    //Add title for empty dataset
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "No vRewards available"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline), NSForegroundColorAttributeName: FlatWhite()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    //Add description/subtitle on empty dataset
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Get rewarded for your loyalty. Deals sent to you personally by venue owners will be found here!"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body), NSForegroundColorAttributeName: FlatGray()]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    @IBAction func contactButtonClicked(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular),
            kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Email", backgroundColor: FlatPurple(), action: {
            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        })
        
        alertView.addButton("Rate Our App", backgroundColor: FlatBlue(), action: {
            self.rateApp(appId: "id1267863034", completion: { (isComplete) in
                
            })
        })
        
        
        alertView.addButton("Maybe Later",  action: {
        })
        
        
        alertView.showInfo("Thank you for using ViiMe!", subTitle: "Our team is working hard to bring your next adVenture one heartbeat closer. \n\nPlease feel free to share your feedback and the features you want to see in the next version.")
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["support@viime.ca"])
        mailComposerVC.setSubject("ViiMe Feedback")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alertView = SCLAlertView()
        alertView.showError("Failed to send email", subTitle: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: Helpers
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    
    
    
}
