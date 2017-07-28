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

class ProfileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var couponsTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var benefitsTableView: UITableView!
    
   
 
 
    var ref: DatabaseReference!
    var user: User!
    let genders = ["", "Male", "Female"]
    var profileURL = ""
    var imagePicker: UIImagePickerController!
    let screenSize = UIScreen.main.bounds

    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = FlatBlack()
    
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
    
        // Check back end to see if user exists
        let productRef = ref.child("users/\(user!.uid)")
        productRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            if ((postDict["name"]) != nil) {
                self.nameTextField.text = postDict["name"] as? String
            }

            if ((postDict["profile"]) != nil) {
                self.profileURL = postDict["profile"]! as! String
                self.profilePicture.downloadedFrom(link: (postDict["profile"] as? String)!)
            }
            
            if ((postDict["email"]) != nil) {
                self.emailTextField.text = postDict["email"] as? String
                print("Change")
            }
            
            if ((postDict["age"]) != nil) {
                print("Here")
                self.ageTextField.text = postDict["age"] as? String
            }
            
            if ((postDict["gender"]) != nil) {
                self.genderTextField.text = postDict["gender"] as? String
            }
            
        })
        
        //Profile Image
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2.0
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = FlatGray().cgColor
        profilePicture.layer.masksToBounds = true
      
        
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        profilePicture.addGestureRecognizer(photoTapGesture)
        
        
        let cameraIcon = UIImage(named: "camera.png")
        let tintedImage = cameraIcon?.withRenderingMode(.alwaysTemplate)
        imageView.image = tintedImage
        imageView.tintColor = FlatWhite()
        
     
        // Textfield setup
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
    
    
    func takePhoto()
    {
        
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
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePicture.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = image
        } else {
            profilePicture.image = nil
        }
        
        if (profilePicture.image != nil) {
            // Points to the root reference
            let storageRef = Storage.storage().reference()
            
            // Points to "images"
            let imagesRef = storageRef.child("images")
            
            // Points to "images/space.jpg"
            // Note that you can use variables to create child values
            let fileName = user.uid + ".jpg"
            let imageRef = imagesRef.child(fileName)
            
         
            var data = Data()
            data = UIImageJPEGRepresentation(profilePicture.image!, 0.8)!
            // set upload path
            let filePath = "\(Auth.auth().currentUser!.uid)/\("userPhoto")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"

            
        }
        
    }
    
    // MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === self.ageTextField) {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
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
                print(index!)
                if (index != nil) {
                    picker.selectRow(index!, inComponent:0, animated:true)
                }
            }
         
 
        
        }
    }
    
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
    
    
    // UITextFieldDelegate Functions and functions relating to textfields
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
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let name =  nameTextField.text
        let age = ageTextField.text
        let email = emailTextField.text
        let gender = genderTextField.text
        
        print ("Test1")
        self.ref.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            self.ref.child("users/\(self.user!.uid)").setValue(["name": name, "age": age, "email": email, "gender": gender, "id": self.user!.uid, "profile": self.profileURL])
        })
        
        print("test2")
    }

    @IBAction func dismissProfilePage(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
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

    
    // Picker View
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
    
    // IB Actions
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
