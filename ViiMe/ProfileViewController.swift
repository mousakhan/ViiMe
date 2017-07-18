//
//  ProfileViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var benefitsTableView: UITableView!
    
    @IBOutlet weak var couponsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = FlatBlack()
        
        //Profile Image
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2.0
        profilePicture.backgroundColor = FlatGray()
        profilePicture.layer.masksToBounds = true

        // Textfield setup
        setupTextField(textfield: nameTextField)
        setupTextField(textfield: emailTextField)
        setupTextField(textfield: birthdayTextField)
        setupTextField(textfield: genderTextField)
        
        // Tableview set up
        setupTableview(tableView: benefitsTableView)
        setupTableview(tableView: couponsTableView)
    }
  
    func setupTextField(textfield: UITextField) {
        textfield.backgroundColor = FlatBlackDark()
        textfield.layer.borderColor = FlatGrayDark().cgColor
        textfield.layer.borderWidth = 0.5
        textfield.layer.masksToBounds = true
    }
    
    func setupTableview(tableView: UITableView) {
        tableView.backgroundColor = FlatBlackDark()
        tableView.separatorColor = FlatGray()
        tableView.layer.borderColor = FlatGrayDark().cgColor
        tableView.layer.borderWidth = 0.5
        tableView.layer.masksToBounds = true
    }

    

    @IBAction func dismissProfilePage(_ sender: Any) {
        
        self.dismiss(animated: true) { 
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
