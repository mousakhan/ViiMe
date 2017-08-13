//
//  RedemptionViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework

class RedemptionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change color of icon button, could probably make this into it's own helper function
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        
        self.dealTitleLabel.text = deal.title
        collectionView.delegate  = self
        collectionView.dataSource = self
        
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: reusableIdentifier)
        
        self.users = self.users.filter { $0.id != "" }
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
    
    
    
    //MARK: IBActions
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
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
