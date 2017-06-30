//
//  VenuesViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-14.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework

class VenuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var searchBar : UISearchBar =  UISearchBar()
    
    @IBAction func showSearchField(_ sender: Any) {
        UIView.animate(withDuration: 1.0) {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.titleView = self.searchBar
        }
        
    }
    @IBOutlet weak var tableView: UITableView!
    
    let venues: [String] = ["Deal 1", "Deal 2", "Deal 3"]
    let cellReuseIdentifier = "VenuesCell";
    var buttons  = [UIButton]()
    var deals = [[], [], []]
    //Seperated out table view in case in the future we add more to this page.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = FlatBlackDark()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // View set up
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 75))
        headerView.tag = section
        headerView.backgroundColor = FlatBlackDark()
        headerView.layer.borderWidth = 0.5
        headerView.layer.borderColor = FlatGray().cgColor
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openSection(sender:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        headerView.addGestureRecognizer(tapGesture)

        
        // Venue Logo
        let venueLogo = UIImage(named: "OttawaNightLife")
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        imageView.image = venueLogo;
        imageView.layer.masksToBounds = true;
        imageView.layer.cornerRadius = 30
        headerView.addSubview(imageView)
        
        // Venue Info Button
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = FlatGray();
        infoButton.frame = CGRect(x: tableView.bounds.size.width - 50, y: 15, width: 20, height: 20)
        infoButton.addTarget(self, action: #selector(showInfo(sender:)), for: .touchUpInside)
        headerView.addSubview(infoButton)
        
        // Venue Name Label
        let venueNameLabel = UILabel(frame: CGRect(x: imageView.frame.origin.x + imageView.frame.size.width + 10, y: 10, width: 125, height: 30))
        venueNameLabel.text = "The Whiskey Bar"
        venueNameLabel.textColor = FlatGray()
        venueNameLabel.font = venueNameLabel.font.withSize(15)
        headerView.addSubview(venueNameLabel)
        headerView.addSubview(venueNameLabel)
        
        // Venue Type Label
        let venueTypeLabel = UILabel(frame: CGRect(x: imageView.frame.origin.x + imageView.frame.size.width + 10, y: 30, width: 100, height: 30))
        venueTypeLabel.text = "Bar"
        venueTypeLabel.textColor = FlatGray()
        venueTypeLabel.font = venueTypeLabel.font.withSize(12)
        headerView.addSubview(venueTypeLabel)
        
        
        //  Expand  and collapse
        let expandButton = UIButton()
        var origImage = UIImage()
        if (deals[section].count == 0) {
            origImage = UIImage(named: "expand")!
        } else {
            origImage = UIImage(named: "collapse")!
        }
        
        let tintedImage = origImage.withRenderingMode(.alwaysTemplate)
        expandButton.setImage(tintedImage, for: .normal)
        expandButton.tintColor = FlatWhite()
        expandButton.frame = CGRect(x: tableView.bounds.size.width - 50, y: 45, width: 20, height: 20)
        headerView.addSubview(expandButton)
        
        return headerView;
    }
    

    func showInfo(sender: AnyObject) {
    }
    
    func openSection(sender: AnyObject){
        if (deals[sender.view.tag].count == 0) {
            deals[sender.view.tag] = ["yee boy", "G", "C"]
        } else {
            deals[sender.view.tag] = []
        }
        tableView.reloadSections(IndexSet([sender.view.tag]), with: UITableViewRowAnimation.automatic)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deals[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.venues.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.venues[section];
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 75;
    }
    
 
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell.layer.borderColor = FlatPurpleDark().cgColor
        cell.layer.borderWidth = 0.5
        cell.backgroundColor = FlatBlack()
        
        cell.textLabel?.font = cell.textLabel?.font.withSize(15)
        // set the text from the data model
        cell.textLabel?.textColor = ContrastColorOf(FlatBlackDark(), returnFlat: true)
        cell.detailTextLabel?.textColor = ContrastColorOf(FlatBlackDark(), returnFlat: true)
        cell.textLabel?.text = self.venues[indexPath.row]
        cell.detailTextLabel?.text = "Bar"
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.backgroundColor = FlatBlackDark()
        view.tintColor = FlatBlackDark()
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
