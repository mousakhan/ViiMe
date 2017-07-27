//
//  DealTableViewCell.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-23.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit

class DealTableViewCell: UITableViewCell {


    
    
    @IBOutlet weak var dealActionLabel: UILabel!
    @IBOutlet weak var dealDescriptionLabel: UILabel!
    let offset = CGFloat(5)
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
     
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
