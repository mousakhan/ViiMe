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

class VenuesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        return 15
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let logo = UIImageView(frame: CGRect(x: cell.bounds.size.width/2.0 - cell.frame.size.width/4.0, y: 15, width: cell.frame.size.width/2.0, height: cell.frame.size.width/2.0))
        logo.layer.cornerRadius = cell.frame.size.width/4.0
        logo.backgroundColor = FlatGray()
        logo.layer.masksToBounds = true
        
        
        let middle = cell.frame.size.width/2.0;
        
        
        
        let bar = UIView(frame: CGRect(x: 0, y: cell.frame.size.height - cell.frame.size.height/7.0, width: cell.frame.size.width, height: cell.frame.size.height/7.0))
        bar.backgroundColor = UIColor(red: 63.0/255, green: 38.0/255, blue: 130.0/255, alpha: 1.0)
        cell.addSubview(logo)
        

        let priceIconFrame = CGRect(x: middle - 30, y: cell.frame.size.height - bar.frame.size.height * 3.0, width: 12, height: 12)
        let priceIcon = addIconToCard(name: "price", frame: priceIconFrame)
        let priceIconLabelFrame = CGRect(x: priceIconFrame.origin.x + priceIconFrame.size.width + 5, y: cell.frame.size.height - bar.frame.size.height * 3.0, width: 40, height: 15)
        let priceLabel = UILabel(frame: priceIconLabelFrame)

        priceLabel.font = priceLabel.font.withSize(11)
        priceLabel.textColor = FlatWhite()
        priceLabel.text = "TesTESTS"
        priceLabel.numberOfLines = 1
        priceLabel.adjustsFontSizeToFitWidth = true
        
     
        
        cell.addSubview(priceLabel)
        
       
        let distanceIconFrame = CGRect(x: middle +  10, y: cell.frame.size.height - bar.frame.size.height * 3.0, width: 12, height: 12)
        let distanceIcon = addIconToCard(name: "distance", frame: distanceIconFrame)
        
        
        let distanceIconLabelFrame = CGRect(x: distanceIconFrame.origin.x + distanceIconFrame.size.width + 5, y: cell.frame.size.height - bar.frame.size.height * 3.0, width: 40, height: 15)
        let distanceLabel = UILabel(frame: distanceIconLabelFrame)
        
        
        
        distanceLabel.font = priceLabel.font.withSize(11)
        distanceLabel.textColor = FlatWhite()
        distanceLabel.text = "1000km"
        distanceLabel.numberOfLines = 1
        distanceLabel.adjustsFontSizeToFitWidth = true
        
     
        
        

        cell.addSubview(distanceLabel)
        
        cell.addSubview(bar)
        
        cell.addSubview(priceIcon)
        cell.addSubview(distanceIcon)
        cell.backgroundColor = FlatBlackDark()
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = FlatGrayDark().cgColor
        // Configure the cell
    
        return cell
    }
    
    
    func addIconToCard(name: String, frame: CGRect) -> UIImageView {
        let priceIcon = UIImageView(frame: frame)
        let tintedImage = (UIImage(named:name))?.withRenderingMode(.alwaysTemplate)
        priceIcon.image = tintedImage
        priceIcon.tintColor = FlatWhiteDark()
        priceIcon.layer.masksToBounds = true
        return priceIcon
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
