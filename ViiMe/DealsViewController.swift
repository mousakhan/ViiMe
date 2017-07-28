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
    
    let reuseIdentifier = "DealCell"
    var deal = "With the purchase of two Donairs, free small fries. With the purchase of two Donairs, free small fries. With the purchase of two Donairs, free small fries. With the purchase of two Donairs, free small fries."
    var venue : Venue?
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(venue!)
        
        self.view.backgroundColor = FlatBlack()
        self.tableView.layer.borderColor = FlatWhiteDark().cgColor
        self.tableView.layer.borderWidth = 0.5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    //MARK: UITableView DataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? DealTableViewCell
        
        cell?.backgroundColor = FlatBlackDark()
        
        cell?.dealDescriptionLabel.textColor = FlatWhite()
        cell?.dealDescriptionLabel.text = deal
        cell?.dealDescriptionLabel.font = cell?.dealDescriptionLabel.font.withSize(12)
        cell?.dealDescriptionLabel.numberOfLines = 0
        
        cell?.dealActionLabel.textColor = FlatWhite()
        cell?.dealActionLabel.text = "INVITE 10 FRIENDS"
        cell?.dealActionLabel.font = cell?.dealActionLabel.font.withSize(12)
        cell?.dealActionLabel.textColor = FlatWhite()
        
        return cell!
    }
}
