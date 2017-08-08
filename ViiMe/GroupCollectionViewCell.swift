//
//  GroupCollectionViewswift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-08.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework

class GroupCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setupViews()
    }
    

    var users : Array<UserInfo> = []
    var numOfPeople = 0
    
    let cancelButton: UIButton = {
        let button = UIButton()
        // Change color of icon button, could probably make this into it's own helper function
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = UIColor.white
        button.titleLabel?.text = ""
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = FlatWhite()
        label.text = "BesBest New AppsBest New AppsBest New AppsBest New Appst New Apps"
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let appsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupViews() {
        backgroundColor = FlatBlackDark()
        
        addSubview(appsCollectionView)
        addSubview(dividerLineView)
        addSubview(nameLabel)
        cancelButton.frame = CGRect(x: frame.origin.x + 5, y: frame.origin.y + 5, width: 15, height: 15)
        addSubview(cancelButton)
        
        appsCollectionView.dataSource = self
        appsCollectionView.delegate = self
        
        appsCollectionView.register(UserCell.self, forCellWithReuseIdentifier: cellId)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-25-[v0]-14-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": dividerLineView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[nameLabel(30)][v0][v1(0.5)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": appsCollectionView, "v1": dividerLineView, "nameLabel": nameLabel]))
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfPeople
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserCell
      
        if (indexPath.row > (self.users.count-1)) {
            cell.nameLabel.text = "Invite"
            cell.profilePicture.image = UIImage(named: "invite")
            cell.profilePicture.image = cell.profilePicture.image?.withRenderingMode(.alwaysTemplate)
            cell.profilePicture.tintColor = FlatGray()
            
        } else {
        let name =  self.users[indexPath.row].name
        cell.nameLabel.text = name
        let profile =  self.users[indexPath.row].profile
        if (profile != "") {
            let url = URL(string: profile)
            cell.profilePicture.kf.indicatorType = .activity
            cell.profilePicture.kf.setImage(with: url)
        } else {
            cell.profilePicture.image = UIImage(named: "empty_profile")
        }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.height/3.0, height: frame.height/2.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    
}

class UserCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var profilePicture = UIImageView()
    var nameLabel = UILabel()
    var statusLabel = UIImageView()
    
    func setupViews(){
        backgroundColor = UIColor.clear
        profilePicture.frame = CGRect(x: frame.size.width/2.0 - 25, y: 5, width: 50, height: 50)
        profilePicture.layoutIfNeeded()
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = FlatGray().cgColor
        profilePicture.backgroundColor = UIColor.clear
        profilePicture.contentMode = .scaleAspectFill   
        
        nameLabel.frame = CGRect(x: frame.size.width/2.0 - 25, y: 55, width: profilePicture.frame.size.width, height: 25)
        nameLabel.textColor = FlatWhite()
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        addSubview(profilePicture)
        addSubview(nameLabel)
    }
}
