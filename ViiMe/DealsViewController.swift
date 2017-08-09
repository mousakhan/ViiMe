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
    
    //TODO: Clean up naming
    @IBOutlet weak var venueInfoView: UIView!
    @IBOutlet weak var aboutThisVenueLabel: UILabel!
    @IBOutlet weak var venueDescription: UITextView!
    @IBOutlet weak var venueDeals: UILabel!
    
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
    
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!

    @IBOutlet weak var venueDescriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = FlatBlack()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = FlatBlack()
        
        self.navigationController?.navigationBar.tintColor = FlatWhite()
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = venue!.name
        
        aboutThisVenueLabel.addBottomBorderWithColor(color: FlatGray(), width: 1)
        venueDeals.addBottomBorderWithColor(color: FlatGray(), width: 1)
        
        let url = URL(string: venue!.logo)
        venueLogo.kf.indicatorType = .activity
        venueLogo.kf.setImage(with: url)
        
        venueDescription.text = venue!.description
        priceLabel.text = venue!.price
        addressLabel.text = venue!.address
        venueTypeLabel.text = venue!.type
        cuisineLabel.text = venue!.cuisine
        websiteLabel.text = venue!.website
        phoneNumberLabel.text = venue!.number
        
        
        // Adding icon and changing color
        addIcon(name: "phone", imageView: phoneIcon)
        addIcon(name: "website", imageView: websiteIcon)
        addIcon(name: "address", imageView: addressIcon)
        addIcon(name: "distance", imageView: distanceIcon)
        addIcon(name: "cuisine", imageView: cuisineIcon)
        addIcon(name: "price", imageView: priceIcon)
        addIcon(name: "type", imageView: venueTypeIcon)
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
        cell.textLabel?.text = venue?.deals[indexPath.row].title
        cell.textLabel?.textColor = FlatWhite()
        cell.textLabel?.font = cell.textLabel?.font.withSize(12 )
        cell.detailTextLabel?.text = "Group of \(venue!.deals[indexPath.row].numberOfPeople) required"
        cell.detailTextLabel?.textColor = FlatWhite()
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.withSize(10)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = FlatPurpleDark()
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }

    //MARK: Helper
    func addIcon(name: String, imageView : UIImageView) {
        imageView.image = UIImage(named: name)
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = FlatGray()
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CreateGroupViewControllerSegue") {
            let destVC = segue.destination as? CreateGroupViewController
            destVC?.venue = self.venue
            let index = tableView.indexPathForSelectedRow?.row
            destVC?.deal = self.venue?.deals[index!]
        }
    }


}
