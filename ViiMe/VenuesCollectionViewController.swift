//
//  VenuesCollectionViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-06.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework

private let reuseIdentifier = "VenueCell"
private let sectionInsets = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 25.0, right: 10.0)
private let iconSize = CGFloat(12.0)
private let offset = CGFloat(5.0)
private let labelWidth = CGFloat(35.0)


class VenuesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate  {
    

    @IBOutlet var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet var profileBarButtonItem: UIBarButtonItem!
    var searchController : UISearchController!
    
    // This will be with VENUE objects in the future when implemented with backend.
    var filteredVenues = [Venue]()
    var venues = [Venue]()
    let venue1 = Venue(name: "The Whiskey Bar", numberOfDeals: 5, price: 20.0, cuisine: "Viet", type: "Bar", distance: 58)

    let venue2 = Venue(name: "The  Bar", numberOfDeals: 10, price: 27.0, cuisine: "Chinese", type: "Club", distance: 161)

    let venue3 = Venue(name: "The Student Bar", numberOfDeals: 6, price: 10.0, cuisine: "Iranian", type: "Pub", distance: 161)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        venues.append(venue1)
        venues.append(venue2)
        venues.append(venue3)
     
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.definesPresentationContext = true
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = FlatWhite()
       
    
        // Register cell classes
        self.collectionView!.register(VenueCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredVenues = venues.filter { venue in
            return venue.name.lowercased().contains(searchText.lowercased())
        }
        
 
        
 
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        collectionView?.reloadData()
    }
    
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
    
    @IBAction func searchBarButtonClicked(_ sender: Any) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.isActive = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
        self.navigationItem.leftBarButtonItem = self.profileBarButtonItem
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        // Cell set up
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VenueCollectionViewCell
    
        
        var venue = Venue(name: "", numberOfDeals: 5, price: 20, cuisine: "Vietnamese", type: "Bar", distance: 58)

        if searchController.isActive && searchController.searchBar.text != "" {
            venue = filteredVenues[indexPath.row]
        } else {
            venue = venues[indexPath.row]
        }
        
    
        cell.nameLabel.text = venue.name
        cell.numberOfDealsLabel.text = String(venue.numberOfDeals) + " Deals"
        cell.priceLabel.text = "$" + String(venue.price)
        cell.cuisineLabel.text = venue.cuisine
        cell.distanceLabel.text = String(venue.distance)
        cell.venueTypeLabel.text = venue.type
      
        return cell
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