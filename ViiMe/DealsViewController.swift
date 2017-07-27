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
    
    
    @IBOutlet weak var groupBarButtonItem: UIBarButtonItem!
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        print(venue!)
     
        self.view.backgroundColor = FlatBlack()
        self.tableView.layer.borderColor = FlatWhiteDark().cgColor
        self.tableView.layer.borderWidth = 0.5
       
   
    }
    
 
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.groupBarButtonItem.customView?.frame = CGRect(x: (self.groupBarButtonItem.customView?.frame.origin.x)! - 15, y: (self.groupBarButtonItem.customView?.frame.origin.y)!, width: (self.groupBarButtonItem.customView?.frame.width)!, height: (self.groupBarButtonItem.customView?.frame.height)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
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
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = FlatPurpleDark()
        cell?.selectedBackgroundView = bgColorView
      
        return cell!
        
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
