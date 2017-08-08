//
//  DealsViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-22.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework


class DealsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let reuseIdentifier = "UITableViewCell"
    var venue : Venue?
    
    @IBOutlet weak var venueInfoView: UIView!
    @IBOutlet weak var aboutThisVenueLabel: UILabel!

    @IBOutlet weak var groupBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var venueLogo: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var venueTypeLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    
    @IBOutlet weak var cuisineIcon: UIImageView!
    @IBOutlet weak var distanceIcon: UIImageView!
    @IBOutlet weak var venueTypeIcon: UIImageView!
    @IBOutlet weak var priceIcon: UIImageView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var websiteIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!

    @IBOutlet weak var venueDescription: UITextView!
  
    @IBOutlet weak var venueDeals: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = FlatBlack()

        tableView.delegate = self
        tableView.dataSource = self

        self.navigationController?.navigationBar.tintColor = FlatWhite()
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = venue!.name
       
   
        aboutThisVenueLabel.addBottomBorderWithColor(color: FlatGray(), width: 1)
        venueDeals.addBottomBorderWithColor(color: FlatGray(), width: 1)
        
        
        let url = URL(string: venue!.logo)
        venueLogo.kf.indicatorType = .activity
        venueLogo.kf.setImage(with: url)
        
        // Set label text
        venueDescription.text = venue!.description
        priceLabel.text = venue!.price
        addressLabel.text = venue!.address
        venueTypeLabel.text = venue!.type
        cuisineLabel.text = venue!.cuisine
        websiteLabel.text = "www.cumberlandpizza.com/"
        phoneNumberLabel.text = "(613) 789-9999"
        
        // Adding icon and changing color
        addIcon(name: "phone", imageView: phoneIcon)
        addIcon(name: "website", imageView: websiteIcon)
        addIcon(name: "address", imageView: addressIcon)
        addIcon(name: "distance", imageView: distanceIcon)
        addIcon(name: "cuisine", imageView: cuisineIcon)
        addIcon(name: "price", imageView: priceIcon)
        addIcon(name: "type", imageView: venueTypeIcon)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        
        // Distance from top is 20, then another 50 for an offset
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: venueInfoView.frame.height + tableView.contentSize.height + 70)
       
    }
    
    override func viewDidLayoutSubviews(){
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        tableView.reloadData()
        
        // Distance from top is 20, then another 50 for an offset
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: venueInfoView.frame.height + tableView.contentSize.height + 70)
     
    }
    
    //MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
     
        cell.backgroundColor = FlatBlackDark()
        cell.textLabel?.text = "Test"
        cell.textLabel?.textColor = FlatWhite()
        cell.textLabel?.font = cell.textLabel?.font.withSize(13)
        
//        cell?.dealDescriptionLabel.textColor = FlatWhite()
//        //cell?.dealDescriptionLabel.text = venue?.deals[indexPath.row].name
//        cell?.dealDescriptionLabel.text = "TEST"
//        cell?.dealDescriptionLabel.font = cell?.dealDescriptionLabel.font.withSize(12)
//        cell?.dealDescriptionLabel.numberOfLines = 0
//        
//        
//        cell?.dealActionLabel.textColor = FlatWhite()
//        cell?.dealActionLabel.text = "Test"
//        cell?.dealActionLabel.font = cell?.dealActionLabel.font.withSize(12)
//        cell?.dealActionLabel.textColor = FlatWhite()
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // self.performSegue(withIdentifier: "RedemptionViewControllerSegue", sender: nil)
    }
  
    //MARK: Helper
    
    func addIcon(name: String, imageView : UIImageView) {
        imageView.image = UIImage(named: name)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = FlatGray()
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
