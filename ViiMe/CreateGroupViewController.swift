//
//  CreateGroupViewController.swift
//  
//
//  Created by Mousa Khan on 2017-08-08.
//
//

import UIKit
import ChameleonFramework

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var venueLogoImageView: UIImageView!
    @IBOutlet weak var venueDealDescriptionLabel: UILabel!
    @IBOutlet weak var venueDealValidityLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    var venue : Venue?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = FlatBlack().withAlphaComponent(0.9)
        
        // Change color of icon button, could probably make this into it's own helper function
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        // Set Logo
        let url = URL(string: venue!.logo)
        venueLogoImageView.kf.indicatorType = .activity
        venueLogoImageView.kf.setImage(with: url)
        
        venueDealDescriptionLabel.text = "This is a test deal"
        venueDealValidityLabel.text = "Valid from July 27th, 2017  at 12:00PM to August 1st, 2017 at 6:00PM"
    
    }

    @IBAction func createGroupButtonPressed(_ sender: Any) {
        let controller = self.presentingViewController as! UINavigationController
        let groupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupCollectionViewController") as! GroupCollectionViewController
        dismiss(animated: true) {
            controller.pushViewController(groupController, animated: true)
        }
    }
    @IBAction func dismissCreateGroupView(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 

}
