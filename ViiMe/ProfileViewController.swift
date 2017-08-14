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

class ProfileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var couponsTableView: UITableView!
    @IBOutlet weak var benefitsTableView: UITableView!
    
    @IBOutlet weak var usernameTextField: UITextField!
   
    var ref: DatabaseReference!
    var user: User!
    var userInfo : UserInfo!
    var groups : Array<Any>! = []
    var deals : Array<Deal>! = []
    var deal : Deal! = nil
    var venues : Array<Venue>! = []
    var venue : Venue! = nil
    var benefits : Array<Any>! = []
    let genders = ["", "Male", "Female"]
    var profileURL = ""
    var imagePicker: UIImagePickerController!

    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = FlatBlack()
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
    
        setupData()
        getGroups { (isComplete) in
            self.benefitsTableView.reloadData()
        }
        //Profile Image Setup
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2.0
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = FlatGray().cgColor
        profilePicture.layer.masksToBounds = true
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        profilePicture.addGestureRecognizer(photoTapGesture)
        
  
        // Textfield setup
        setupTextField(textfield: usernameTextField)
        setupTextField(textfield: nameTextField)
        setupTextField(textfield: emailTextField)
        setupTextField(textfield: ageTextField)
        setupTextField(textfield: genderTextField)
        
        // Tableview set up
        setupTableview(tableView: benefitsTableView)
        setupTableview(tableView: couponsTableView)
        
        // Keyboard Set up
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard(sender:)))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.benefitsTableView) {
            return self.deals.count
        }
        
        return self.benefits.count
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.backgroundColor = FlatBlack()
        cell.textLabel?.textColor  = FlatWhite()
        if (self.deals.count > 0) {
            cell.textLabel?.text = self.deals[indexPath.row].shortDescription
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = cell.textLabel?.font.withSize(12 )
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = FlatPurpleDark()
        cell.selectedBackgroundView = bgColorView
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.benefitsTableView) {
            self.deal = self.deals[indexPath.row]
            self.venue = self.venues[indexPath.row]
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
            self.performSegue(withIdentifier: "GroupCollectionViewSegue", sender: nil)
        }
    }
    
    //MARK: Image Picker
    func takePhoto() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePicture.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = image
        } else {
            profilePicture.image = nil
            profilePicture.image = UIImage(named: "empty_profile")
        }
        
        if (profilePicture.image != nil) {
            
            let storageRef = Storage.storage().reference().child("profile/ " + userInfo.id + ".png")
    
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    print("Deleted!")
                    // File deleted successfully
                }
            }
            
            
            if let uploadData = UIImagePNGRepresentation(profilePicture.image!) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }                    
                    Database.database().reference().root.child("users").child(self.userInfo.id).updateChildValues(["profile": metadata?.downloadURL()?.absoluteString ?? ""])
                    
                    
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
        } else if (textField === self.genderTextField) {
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            textField.inputView = picker
            if (self.genderTextField.text != nil) {
                let index = genders.index(of: self.genderTextField.text!)
                if (index != nil) {
                    picker.selectRow(index!, inComponent:0, animated:true)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == nameTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            ageTextField.becomeFirstResponder()
        } else if (textField == ageTextField) {
            genderTextField.becomeFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let username = usernameTextField.text
        let name =  nameTextField.text
        let age = ageTextField.text
        let email = emailTextField.text
        let gender = genderTextField.text
        
        self.ref.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            self.ref.child("users/\(self.user!.uid)").setValue(["username": username, "name": name, "age": age, "email": email, "gender": gender, "id": self.userInfo.id, "profile": self.userInfo.profile])
        })
        
    }
    
    //MARK: Helper Functions
    func hideKeyboard(sender: AnyObject) {
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        genderTextField.resignFirstResponder()
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
    
    func setupData() {
        // Check back end to see if user exists
        let productRef = ref.child("users/\(user!.uid)")
        productRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            let username = postDict["username"] as? String ?? ""
            let name = postDict["name"] as? String ?? ""
            let age = postDict["age"] as? String ?? ""
            let gender = postDict["gender"] as? String ?? ""
            let email = postDict["email"] as? String ?? ""
            let profile = postDict["profile"] as? String ?? ""
            let groups = postDict["groups"] as? Dictionary<String, Any> ?? [:]
            let friends = postDict["friends"] as? Array<String> ?? []
            
            if (username != "") {
                self.usernameTextField.text = postDict["username"] as? String
            }
            
            if (name != "") {
                self.nameTextField.text = postDict["name"] as? String
            }
            
            
            if (profile != "") {
                self.profileURL = profile
                let url = URL(string: profile)
                self.profilePicture.kf.indicatorType = .activity
                self.profilePicture.kf.setImage(with: url)
            } else {
                self.profilePicture.image = UIImage(named: "empty_profile")
            }
            
            if (email != "") {
                self.emailTextField.text = postDict["email"] as? String
            }
            
            if (age != "") {
                self.ageTextField.text = postDict["age"] as? String
            }
            
            if (gender != "") {
                self.genderTextField.text = postDict["gender"] as? String
            }
            
            self.userInfo = UserInfo(username: username, name: name, id: self.user.uid, age: age, email: email, gender: gender, profile: profile, status: "", groups: groups, friends: friends)
            
        })
    }
    
    // This'll fetch all the informationg relating to the groups of this venue for the user
    func getGroups(completionHandler: @escaping (_ isComplete: Bool) -> ()){
        let ref = Database.database().reference().child("groups")
        ref.observe(DataEventType.value, with:{ (snapshot: DataSnapshot) in
            self.groups = []
            self.deals = []
            self.venues = []
            for (key, _) in self.userInfo.groups {
                var dict = [String: Any]()
                for child in snapshot.childSnapshot(forPath: key ).children {
                    let key = (child as! DataSnapshot).key
                    if (key == "deal-id") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["deal-id"] = value
                        self.getDeal(id: value, completionHandler: { (isComplete) in
    
                            if (isComplete) {
                                self.benefitsTableView.reloadData()
                            }
                        })
                    } else if (key == "id") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["id"] = value
                    } else if (key == "users") {
                        let value = (child as! DataSnapshot).value as! NSDictionary
                        dict["users"] = value
                    } else if (key == "usersStatuses") {
                        let value = (child as! DataSnapshot).value as! Array<Bool>
                        dict["usersStatuses"] = value
                    } else if (key == "created") {
                        let value = (child as! DataSnapshot).value as! Int
                        dict["created"] = value
                    } else if (key == "owner") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["owner"] = value
                    } else if (key == "venue-id") {
                        let value = (child as! DataSnapshot).value as! String
                        dict["venue-id"] = value
                        self.getVenue(id: value, completionHandler: { (isComplete) in
                            if (isComplete) {
                                self.benefitsTableView.reloadData()
                            }
                        })
                        
                    }
                }
                
                if (dict.count > 0) {
                    self.groups.append(dict)
                    self.groups = self.groups.sorted { (($0 as! Dictionary<String, Any>)["created"] as! Int)  > (($1 as! Dictionary<String, Any>)["created"] as! Int) }
                }
            }
            completionHandler(true)
        })
        
    
    }
    
    func getDeal(id : String, completionHandler: @escaping (_ isComplete: Bool) -> ()) {
        if (id != "") {
            Database.database().reference().child("deal/\(id)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let title = value?["title"] ?? ""
                let shortDescription = value?["short-description"] ?? ""
                let longDescription = value?["long-description"] ?? ""
                let numberOfRedemptions = value?["num-redemptions"] ?? ""
                let numberOfPeople = value?["number-of-people"] ?? ""
                let id = value?["id"] ?? ""
                let validFrom = value?["valid-from"] ?? ""
                let validTo = value?["valid-to"] ?? ""
                let recurringFrom = value?["recurring-from"] ?? ""
                let recurringTo = value?["recurring-to"] ?? ""
                
                let deal = Deal(title: title as! String, shortDescription: shortDescription as! String, longDescription: longDescription as! String, id: id as! String, numberOfPeople: numberOfPeople as! String, numberOfRedemptions: numberOfRedemptions as! String, validFrom: validFrom as! String, validTo: validTo as! String, recurringFrom: recurringFrom as! String, recurringTo: recurringTo as! String)
                
                if (DateHelper.checkDateValidity(validFrom: validFrom as! String, validTo: validTo as! String, recurringFrom: recurringFrom as! String, recurringTo: recurringTo as! String)) {
                    self.deals.append(deal)
                }
                completionHandler(true)
            })
        }
        
    }
    
    
    func getVenue(id : String, completionHandler: @escaping (_ isComplete: Bool) -> ()) {
        if (id != "") {
            Database.database().reference().child("venue/\(id)").observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let name = value?["name"] ?? ""
                let id = value?["id"] ?? ""
                _ = value?["cuisine"] ?? []
                let cuisine =  ""
                let description = value?["description"] ?? ""
                let price = value?["price"] ?? ""
                let address = value?["address"] ?? ""
                let website = value?["website"] ?? " "
                let number = value?["number"] ?? " "
                let type = value?["type"] ?? ""
                let code = value?["code"] ?? ""
                let deals = value?["deals"] ?? {}
                let profile = value?["logo"] ?? ""
                let venue = Venue(name: name as! String, id: id as! String, price: price as! String, code: code as! String, cuisine: cuisine , type: type as! String, address: address as! String, description: description as! String, distance: "", logo: profile as! String, website: website as! String, number: number as! String, deals: [])
                self.venues.append(venue)
                completionHandler(true)
            })
        }
        
    }
    
    //MARK: Picker View Delegate & Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField.text = genders[row]
    }
    
    //MARK: IBActions
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        
        if ((FBSDKAccessToken.current()) != nil) {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        
        let presentingViewController = self.presentingViewController
        self.dismiss(animated: false, completion: {
            presentingViewController!.dismiss(animated: true, completion: {})
        })
        
    }
    
    @IBAction func dismissProfilePage(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GroupCollectionViewSegue") {
            let destVC = segue.destination as? GroupCollectionViewController
            destVC?.ids = self.userInfo!.groups
            destVC?.venue = self.venue!
            destVC?.deal = self.deal!
            destVC?.user = self.userInfo!
        }
    }
    

}
