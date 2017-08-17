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
import CoreLocation

class VenuesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet var searchBarButtonItem: UIBarButtonItem!
    
    var searchController : UISearchController!
    let reuseIdentifier = "VenueCell"
    let locationManager = CLLocationManager()
    var currCoordinate = CLLocation(latitude: 0.0, longitude: 0.0)
    var filteredVenues = [Venue]()
    var venues = [Venue]()
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
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
        
        // Changing navigation tint color to white
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = FlatWhite()
        
        // Register cell classes
        self.collectionView!.register(VenueCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initVenues()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Constants.refs.root.removeAllObservers()
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        let sectionInsets = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 25.0, right: 10.0)
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
        
        var venue : Venue? = nil
        
        if searchController.isActive && searchController.searchBar.text != "" {
            venue = filteredVenues[indexPath.row]
        } else {
            venue = venues[indexPath.row]
        }
        
        cell.nameLabel.text = venue?.name
        cell.numberOfDealsLabel.text = "\(venue?.deals.count ?? 0) Deals"
        cell.priceLabel.text = venue?.price ?? ""
        cell.cuisineLabel.text = venue?.cuisine ?? ""
        setDistance(address: venue?.address ?? "", completionHandler: { (isComplete, distance) in
            if (isComplete) {
                cell.distanceLabel.text = distance
            }
        })
        cell.venueTypeLabel.text = venue?.type ?? ""
        
        
        let url = URL(string: venue?.logo ?? "")
        cell.logo.kf.indicatorType = .activity
        cell.logo.kf.setImage(with: url)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DealViewControllerSegue", sender: nil)
    }
    
    
    //MARK: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredVenues = venues.filter { venue in
            // Search by name, venue type, venue cuisine or price
            return venue.name.lowercased().contains(searchText.lowercased()) || venue.type.lowercased().contains(searchText.lowercased()) || venue.cuisine.lowercased().contains(searchText.lowercased()) ||  venue.price.lowercased().contains(searchText.lowercased())
        }
        
        collectionView?.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.setHidesBackButton(false, animated:true)
        self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
        searchController.searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
        self.navigationItem.setHidesBackButton(false, animated:true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: IBActions
    @IBAction func searchBarButtonClicked(_ sender: Any) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated:true)
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
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currCoordinate = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    }
    
    //MARK: Helpers
    
    // This will grab all the venues from the back-end
    func initVenues () {
        // Go to back-end 'venue' node and fetch every venue
        Constants.refs.venues.observe(DataEventType.value, with: { (snapshot) in
            self.venues = []
            let enumerator = snapshot.children
            //Iterate through the venues, keep track of an index
            var index = -1
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let venue = Venue(snapshot: rest)
                self.venues.append(venue)
                index = index + 1
                // Check if deals actually exist
                if venue.dealIds.count != 0 {
                    // If they do, laod the deal
                    self.getDeal(ids: venue.dealIds , completionHandler: { (isComplete, deal) in
                        // If a deal is loaded, then add it to the venue
                        if (isComplete) {
                            self.venues[index].deals.append(deal)
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                    })
                    self.collectionView?.reloadData()
                }
            }
        })
        
    }
    
    // This function will take in a group of deal ids, and return with each deal
    func getDeal(ids : Dictionary<String, Bool>, completionHandler: @escaping (_ isComplete: Bool, _ deal: Deal) -> ()){
        // Loop through ids
        for (key, isActive) in ids {
            // If deal is active for, then search for the deal
            if (isActive) {
                // Go to back-end
                Constants.refs.deals.child(key).observeSingleEvent(of: DataEventType.value, with: { snapshot in
                    let deal = Deal(snapshot: snapshot)
                    
                    // If deal is valid, then return with a true boolean and the deal
                    if (DateHelper.checkDateValidity(validFrom: deal.validFrom, validTo: deal.validTo, recurringFrom: deal.recurringFrom, recurringTo: deal.recurringTo)) {
                        completionHandler(true, deal)
                    }
                    
                    // Return with false
                    completionHandler(false, deal)
                })
            }
        }
    }
    
    // This will take an addrse and calculate the distance between the two points, and will return the distance as a string
    func setDistance(address : String, completionHandler: @escaping (_ isComplete: Bool, _ distance: String) -> ()) {
        if (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            let geocoder = CLGeocoder()
            var coordinate : CLLocation? = nil
            geocoder.geocodeAddressString(address) {
                placemarks, error in
                let placemark = placemarks?.first
                let lat = placemark?.location?.coordinate.latitude
                let lon = placemark?.location?.coordinate.longitude
                var distance = ""
                if (lat != nil && lon != nil) {
                    coordinate = CLLocation(latitude: lat!, longitude: lon!)
                    let distanceInMeters = Int(self.currCoordinate.distance(from: coordinate!))
                    distance = "\(distanceInMeters/1000)km"
                } else {
                    distance = "?"
                }
                completionHandler(true, distance)
            }
        } else {
            completionHandler(true, "?")
        }
        
        
        
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
