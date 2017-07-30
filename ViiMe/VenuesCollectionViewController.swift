//
//  VenuesCollectionViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-06.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseDatabase
import Kingfisher


class VenuesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate  {
    
    @IBOutlet var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet var profileBarButtonItem: UIBarButtonItem!
    var searchController : UISearchController!
    
    let reuseIdentifier = "VenueCell"
    let sectionInsets = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 25.0, right: 10.0)
    let iconSize = CGFloat(12.0)
    let offset = CGFloat(5.0)
    let labelWidth = CGFloat(35.0)
    
    var filteredVenues = [Venue]()
    var venues = [Venue]()
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initVenues()
        
        // Search Controller setup
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .done
        self.searchController.searchBar.enablesReturnKeyAutomatically = false
        self.searchController.searchBar.keyboardAppearance = .dark
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = FlatWhite()
       
    
        // Register cell classes
        self.collectionView!.register(VenueCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warnig Incomplete implementation, return the number of items
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredVenues.count
        }
        
        return venues.count
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = sectionInsets
        let numberOfItemsPerRow = 2
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        
        return CGSize(width: size, height: size + 25)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VenueCollectionViewCell
    
        
    
        var venue = Venue(name: "", price: "", cuisine: "", type: "", address: "", description: "", profileUrl: "")
        
        if searchController.isActive && searchController.searchBar.text != "" {
            venue = filteredVenues[indexPath.row]
        } else {
            venue = venues[indexPath.row]
        }
        
    
        cell.nameLabel.text = venue.name
        cell.numberOfDealsLabel.text = "2"
        cell.priceLabel.text = "" + venue.price
        cell.cuisineLabel.text = venue.cuisine
        cell.distanceLabel.text = venue.address
        cell.venueTypeLabel.text = venue.type
        
        let url = URL(string: venue.profileUrl)
        cell.logo.kf.setImage(with: url)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DealViewControllerSegue", sender: nil)
    }
    

    //MARK: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredVenues = venues.filter { venue in
            return venue.name.lowercased().contains(searchText.lowercased())
        }
        
        collectionView?.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
        self.navigationItem.leftBarButtonItem = self.profileBarButtonItem
        searchController.searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
        self.navigationItem.leftBarButtonItem = self.profileBarButtonItem
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    //MARK: IBActions
    @IBAction func searchBarButtonClicked(_ sender: Any) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DealViewControllerSegue") {
            let destVC = segue.destination as! DealsViewController
            if let indexPath = collectionView?.indexPathsForSelectedItems?[0][1] {
                destVC.venue = venues[indexPath]
            }
        }
    }
    
    //MARK: Helpers
    
    func initVenues () {
        let ref = Database.database().reference().child("venue/")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount) // I got the expected number of items
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let name = value?["name"]
                let cuisine = value?["cuisine"] ?? ""
                let description = value?["description"] ?? ""
                let price = value?["price"] ?? ""
                let address = value?["address"] ?? ""
                let type = value?["type"] ?? ""
                let deals = value?["deals"] ?? []
                let profile = value?["profileUrl"] ?? ""
                
                let venue = Venue(name: name as! String, price: price as! String, cuisine: cuisine as! String, type: type as! String, address: address as! String, description: description as! String, profileUrl: profile as! String)
                print (venue)
                self.venues.append(venue)
            }
        })
        
        self.collectionView?.reloadData()
        getDeals()
    }
    
    func getDeals() {
        let ref = Database.database().reference().child("deal/")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount) // I got the expected number of items
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                print(rest)
                print ("Deal")
            }
        })
        
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
