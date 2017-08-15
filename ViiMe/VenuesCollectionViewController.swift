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
    @IBOutlet var profileBarButtonItem: UIBarButtonItem!
    var searchController : UISearchController!
    
    let reuseIdentifier = "VenueCell"
    let sectionInsets = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 25.0, right: 10.0)
    let iconSize = CGFloat(12.0)
    let offset = CGFloat(5.0)
    let labelWidth = CGFloat(35.0)
    let locationManager = CLLocationManager()
    var currCoordinate = CLLocation(latitude: 0.0, longitude: 0.0)
    var filteredVenues = [Venue]()
    var venues = [Venue]()
    var deals = [Deal]()
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
        Database.database().reference().removeAllObservers()
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
        
        
        var venue = Venue(name: "", id: "", price: "", code: "", cuisine: "", type: "", address: "", description: "", distance: "", logo: "", website: "", number: "", deals: [])
        
        if searchController.isActive && searchController.searchBar.text != "" {
            venue = filteredVenues[indexPath.row]
        } else {
            venue = venues[indexPath.row]
        }
        
        cell.nameLabel.text = venue.name
        cell.numberOfDealsLabel.text = "\(venue.deals.count) Deals"
        cell.priceLabel.text = "" + venue.price
        cell.cuisineLabel.text = venue.cuisine
        setDistance(address: venue.address, completionHandler: { (isComplete, distance) in
            if (isComplete) {
                cell.distanceLabel.text = distance
            }
        })
        cell.venueTypeLabel.text = venue.type
        
        let url = URL(string: venue.logo)
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
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currCoordinate = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    }
    
    //MARK: Helpers
    func initVenues () {
        let ref = Database.database().reference().child("venue")
        ref.observe(DataEventType.value, with: { (snapshot) in
            self.venues = []
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let name = value?["name"] ?? ""
                let id = value?["id"] ?? ""
                let cuisines = value?["cuisine"] ?? ""
                var cuisine = ""
                if (cuisines as! String != ""){
                    cuisine = (cuisines as AnyObject).components(separatedBy: ",")[0]
                }
                let description = value?["description"] ?? ""
                let price = value?["price"] ?? ""
                let address = value?["address"] ?? ""
                let website = value?["website"] ?? " "
                let number = value?["number"] ?? " "
                let type = value?["type"] ?? ""
                let code = value?["code"] ?? ""
                let deals = value?["deals"] ?? {}
      
                //TODO: change this naming in the back-end
                let profile = value?["logo"] ?? ""
                var venue = Venue(name: name as! String, id: id as! String, price: price as! String, code: code as! String, cuisine: cuisine , type: type as! String, address: address as! String, description: description as! String, distance: "", logo: profile as! String, website: website as! String, number: number as! String, deals: [])
                if let deals = deals as? NSDictionary {
                self.getDeals(ids: deals , completionHandler: { (isComplete, deals) in
                    if (isComplete) {
                        venue.deals = deals
                        
                        self.venues.append(venue)
                        
                        var seen = Set<String>()
                        var unique = [Venue]()
                        
                        for venue in self.venues.reversed() {
                            if !seen.contains(venue.id) {
                                    unique.insert(venue, at: 0)
                                seen.insert(venue.id)
                            }
                        }
                        
                        self.venues = unique
                        
                        self.collectionView?.reloadData()
                    }
                })
                self.collectionView?.reloadData()
                }
                else {
                    
                }
            }
        })
        
    }
    
    func getDeals(ids : NSDictionary, completionHandler: @escaping (_ isComplete: Bool, _ deal: Array<Deal>) -> ()){
        var deals : Array<Deal> = []
        for (key, _) in ids {
            let ref = Database.database().reference().child("deal/\(key)")
            ref.observe( DataEventType.value, with: { snapshot in
                    let value = snapshot.value as? NSDictionary
                    let title = value?["title"] ?? ""
                    let shortDescription = value?["short-description"] ?? ""
                    let longDescription = value?["long-description"] ?? ""
                    let numberOfPeople = value?["number-of-people"] ?? ""
                    let numberOfRedemptions = value?["num-redemptions"] ?? ""
                    let id = value?["id"] ?? ""
                    let validFrom = value?["valid-from"] ?? ""
                    let validTo = value?["valid-to"] ?? ""
                    let recurringFrom = value?["recurring-from"] ?? ""
                    let recurringTo = value?["recurring-to"] ?? ""
                
                    let deal = Deal(title: title as! String, shortDescription: shortDescription as! String, longDescription: longDescription as! String, id: id as! String, numberOfPeople: numberOfPeople as! String, numberOfRedemptions: numberOfRedemptions as! String, validFrom: validFrom as! String, validTo: validTo as! String, recurringFrom: recurringFrom as! String, recurringTo: recurringTo as! String)
                
                if (DateHelper.checkDateValidity(validFrom: validFrom as! String, validTo: validTo as! String, recurringFrom: recurringFrom as! String, recurringTo: recurringTo as! String)) {
                    deals.append(deal)
                }
                
                completionHandler(true, deals)
            })
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
