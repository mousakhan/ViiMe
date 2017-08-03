//
//  VenueCollectionViewself.contentView.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-14.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework

private let iconSize = CGFloat(12.0)
private let offset = CGFloat(5.0)
private let labelWidth = CGFloat(40.0)

class VenueCollectionViewCell: UICollectionViewCell {
    
    var nameLabel = UILabel()
    var logo = UIImageView()
    var numberOfDealsLabel = UILabel()
    var priceLabel = UILabel()
    var cuisineLabel = UILabel()
    var venueTypeLabel = UILabel()
    var distanceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = FlatBlackDark()
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = FlatGrayDark().cgColor

        
        
        // TODO: Clean up these magic numbers for the label frames
        // Venue Name
        
        nameLabel = UILabel(frame: CGRect(x: 5, y: offset * 2.0, width: self.contentView.frame.size.width - 5, height: 15))
        nameLabel.textAlignment = .center
        nameLabel.font = nameLabel.font.withSize(13)
        nameLabel.textColor = FlatWhite()
        self.contentView.addSubview(nameLabel)
        
        // Venue Logo
        logo = UIImageView(frame: CGRect(x: self.contentView.frame.size.width * 0.3, y: 25 + offset, width: self.contentView.frame.size.width/2.4, height:self.contentView.frame.size.width/2.4))
        logo.contentMode = .scaleAspectFit
        self.contentView.addSubview(logo)

        
        // Deal Bar
        let bar = UIView(frame: CGRect(x: 0, y: self.contentView.frame.size.height - self.contentView.frame.size.height/7.0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height/7.0))
        bar.backgroundColor = UIColor(red: 63.0/255, green: 38.0/255, blue: 130.0/255, alpha: 1.0)
        bar.layer.borderWidth = 0.5
        bar.layer.borderColor = FlatGrayDark().cgColor
        let imgView = UIImageView(frame: CGRect(x: self.contentView.frame.size.width - iconSize * 1.4, y: bar.frame.height/2.0 - iconSize/2.0, width: iconSize, height: iconSize))
        imgView.image = (UIImage(named:"forward"))?.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = FlatWhiteDark()
        imgView.layer.masksToBounds = true
        bar.addSubview(imgView)
        numberOfDealsLabel = UILabel(frame: CGRect(x: offset * 2.0, y: 0, width: bar.frame.width, height: bar.frame.height))
        numberOfDealsLabel.font = numberOfDealsLabel.font.withSize(12)
        numberOfDealsLabel.textColor = FlatWhite()
        bar.addSubview(numberOfDealsLabel)
        self.contentView.addSubview(bar)
        
        let middle = self.contentView.frame.size.width/2.0
        
        // Price Icon and Label
        let priceIconLabelFrame = CGRect(x: middle - labelWidth, y: self.contentView.frame.size.height - bar.frame.size.height * 3.0, width: labelWidth, height: 15)
        let priceIconFrame = CGRect(x: priceIconLabelFrame.origin.x - (iconSize * 1.5), y: self.contentView.frame.size.height - bar.frame.size.height * 3.0, width: iconSize, height: iconSize)
        let priceIcon = addIconToCard(name: "price", frame: priceIconFrame)
        priceLabel = UILabel(frame: priceIconLabelFrame)
        priceLabel.font = priceLabel.font.withSize(10)
        priceLabel.textColor = FlatWhite()
        priceLabel.numberOfLines = 1
        priceLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(priceIcon)
        self.contentView.addSubview(priceLabel)
        

        // Cuisine Icon and Label
        let cuisineIconLabelFrame = CGRect(x: middle - labelWidth, y: self.contentView.frame.size.height - bar.frame.size.height * 3.0 + offset * 4.0, width: labelWidth, height: 15)
        cuisineLabel = UILabel(frame: cuisineIconLabelFrame)
        let cuisineIconFrame = CGRect(x: cuisineIconLabelFrame.origin.x - (iconSize * 1.5), y: self.contentView.frame.size.height - bar.frame.size.height * 3.0 + (offset * 4.0), width: iconSize, height: iconSize)
        let cuisineIcon = addIconToCard(name: "cuisine", frame: cuisineIconFrame)
        cuisineLabel.font = cuisineLabel.font.withSize(10)
        cuisineLabel.textColor = FlatWhite()
        cuisineLabel.numberOfLines = 0
        cuisineLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(cuisineLabel)
        self.contentView.addSubview(cuisineIcon)
        

        // Distance Icon and Label
        let distanceIconFrame = CGRect(x: middle + offset, y: self.contentView.frame.size.height - bar.frame.size.height * 3.0, width: iconSize, height: iconSize)
        let distanceIcon = addIconToCard(name: "distance", frame: distanceIconFrame)
        let distanceIconLabelFrame = CGRect(x: distanceIconFrame.origin.x + (iconSize * 1.5), y: self.contentView.frame.size.height - bar.frame.size.height * 3.0, width: labelWidth, height: 15)
        distanceLabel = UILabel(frame: distanceIconLabelFrame)
        distanceLabel.font = priceLabel.font.withSize(10)
        distanceLabel.textColor = FlatWhite()
        distanceLabel.text = "100" + "km"
        distanceLabel.numberOfLines = 1
        distanceLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(distanceLabel)
        self.contentView.addSubview(distanceIcon)

        
        // Venue Icon and  Label
        let venueTypeIconFrame = CGRect(x: middle + offset, y: self.contentView.frame.size.height - bar.frame.size.height * 3.0 + offset * 4.0, width: iconSize, height: iconSize)
        let venueTypeIcon = addIconToCard(name: "type", frame: venueTypeIconFrame)
        let venueTypeIconLabelFrame = CGRect(x: venueTypeIconFrame.origin.x + (iconSize * 1.5), y: self.contentView.frame.size.height - bar.frame.size.height * 3.0 + offset * 4.0, width: labelWidth, height: 15)
        venueTypeLabel = UILabel(frame: venueTypeIconLabelFrame)
        venueTypeLabel.font = venueTypeLabel.font.withSize(10)
        venueTypeLabel.textColor = FlatWhite()
        venueTypeLabel.text = "Bar"
        venueTypeLabel.numberOfLines = 1
        venueTypeLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(venueTypeLabel)
        self.contentView.addSubview(venueTypeIcon)
        
        
    }
    

    
    
    //MARK: Helper Function
    func addIconToCard(name: String, frame: CGRect) -> UIImageView {
        let icon = UIImageView(frame: frame)
        let tintedImage = (UIImage(named:name))?.withRenderingMode(.alwaysTemplate)
        icon.image = tintedImage
        icon.tintColor = FlatWhiteDark()
        icon.layer.masksToBounds = true
        return icon
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
