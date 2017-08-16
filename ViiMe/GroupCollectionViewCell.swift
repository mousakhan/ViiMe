//
//  GroupCollectionViewswift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-08.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework
import SCLAlertView
import Firebase

protocol UserCollectionViewCellDelegate {
    func invite(index : Int)
    func redeem(index : Int)
    func acceptGroupInvitation(groupIndex : Int)
    func declineGroupInvitation(groupIndex : Int)
}

class GroupCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let reusableIdentifier = "GroupCollectionViewCell"
    
    var delegate: UserCollectionViewCellDelegate?
    var group : Group? = nil
    var groupTag = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setupViews()
    }
    
 
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
    
    let dealLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = FlatWhite()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let usersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let redeemButton: UIButton = {
        let button = UIButton()
        // Change color of icon button, could probably make this into it's own helper function
        button.setTitle("REDEEM", for: .normal)
        button.setTitleColor(FlatWhite(), for: .normal)
        button.backgroundColor = FlatPurpleDark()
        button.setTitleColor(FlatGray(), for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        return view
    }()

    func setupViews() {
        backgroundColor = FlatBlackDark()
        
        addSubview(usersCollectionView)
        addSubview(dealLabel)
        addSubview(cancelButton)
        addSubview(redeemButton)
        addSubview(dividerLineView)
        
        usersCollectionView.dataSource = self
        usersCollectionView.delegate = self
        
        usersCollectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: reusableIdentifier)
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = FlatGrayDark().cgColor
        
        
        // Setting up all the constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        cancelButton.topAnchor.constraint(equalTo: self.topAnchor, constant:5).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        dealLabel.translatesAutoresizingMaskIntoConstraints = false
        dealLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30).isActive = true
        dealLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        dealLabel.topAnchor.constraint(equalTo: self.cancelButton.topAnchor, constant:5).isActive = true
        dealLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
        dividerLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        dividerLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        dividerLineView.topAnchor.constraint(equalTo: self.dealLabel.bottomAnchor).isActive = true
        dividerLineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        usersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        usersCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        usersCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        usersCollectionView.topAnchor.constraint(equalTo: self.dividerLineView.bottomAnchor, constant: -2.0).isActive = true
        
        
        redeemButton.translatesAutoresizingMaskIntoConstraints = false
        redeemButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        redeemButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        redeemButton.topAnchor.constraint(equalTo: self.usersCollectionView.bottomAnchor).isActive = true
        redeemButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        redeemButton.addTarget(self, action: #selector(redeem(sender:)), for: .touchUpInside )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.group?.deal?.numberOfPeople {
            return Int(count) ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifier, for: indexPath) as! UserCollectionViewCell
        
        cell.profilePicture.image = nil
        cell.statusLabel.text = nil
        cell.nameLabel.text = nil

        // Disable and then re-enable depending on the user
        cell.isUserInteractionEnabled = false
        
        // Set the tag for later user
        cell.tag = groupTag
        
        // Check if the group exists
        if (self.group != nil) {
            if (self.group?.deal != nil) {
                dealLabel.text = self.group?.deal?.shortDescription
            }
            
            // The first cell should always be the group owner
            if (indexPath.row == 0 && group?.owner != nil) {
                cell.nameLabel.text = group?.owner?.name
                cell.profilePicture.contentMode = .scaleToFill
                cell.statusLabel.text = "Group Owner"
                // Should not be able to click the group owner cell
                cell.isUserInteractionEnabled = false
                if let profile = self.group?.owner?.profile {
                    if (profile != "") {
                        let url = URL(string: profile)
                        cell.profilePicture.kf.indicatorType = .activity
                        cell.profilePicture.kf.setImage(with: url)
                    } else {
                        cell.profilePicture.image = UIImage(named: "empty_profile")
                    }
                }
            } else {
                // Otherwise, check if there are users
                if (self.group!.users.count > 0 && self.group!.users.count >= indexPath.row) {
                    // This is because the owner isn't included in the users array, need to adjust the index
                    let index = indexPath.row - 1
                    let users = self.group?.users
                    let profile =  users?[index].profile
                    cell.nameLabel.text = users?[index].name
                    if (profile != "") {
                        let url = URL(string: profile!)
                        cell.profilePicture.kf.indicatorType = .activity
                        cell.profilePicture.kf.setImage(with: url)
                    } else {
                        cell.profilePicture.image = UIImage(named: "empty_profile")
                    }
                    cell.profilePicture.contentMode = .scaleToFill
                } else {
                    // If there are no users, then invite
                    cell.nameLabel.text = "Invite"
                    cell.profilePicture.image = UIImage(named: "invite")
                    cell.profilePicture.image = cell.profilePicture.image?.withRenderingMode(.alwaysTemplate)
                    cell.profilePicture.tintColor = FlatGray()
                    cell.profilePicture.contentMode = .center
                    cell.statusLabel.text = ""
                    cell.isUserInteractionEnabled = true
                    
                }
            }
        }
        //        cell.tag = groupTag
        //        cell.profilePicture.image = nil
        //        if (owner != nil && indexPath.row == 0) {
        //            let name =  owner?.name
        //            let profile =  owner?.profile
        //            if (profile != "") {
        //                let url = URL(string: profile!)
        //                cell.profilePicture.kf.indicatorType = .activity
        //                cell.profilePicture.kf.setImage(with: url)
        //            } else {
        //                cell.profilePicture.image = UIImage(named: "empty_profile")
        //            }
        //            cell.nameLabel.text = name
        //            cell.profilePicture.contentMode = .scaleToFill
        //            cell.statusLabel.text = "Group Owner"
        //            cell.isUserInteractionEnabled = false
        //        } else if (self.users.count > 0) {
        //            if ((self.users.count) >= indexPath.row) {
        //                let index = indexPath.row - 1
        //                let name =  self.users[index].name
        //                let profile =  self.users[index].profile
        //                if (profile != "") {
        //                    let url = URL(string: profile)
        //                    cell.profilePicture.kf.indicatorType = .activity
        //                    cell.profilePicture.kf.setImage(with: url)
        //                } else {
        //                    cell.profilePicture.image = UIImage(named: "empty_profile")
        //                }
        //                cell.nameLabel.text = name
        //                cell.profilePicture.contentMode = .scaleToFill
        //                cell.isUserInteractionEnabled = true
        //
        //                if (owner?.id != self.user?.id) {
        //                    cell.isUserInteractionEnabled = false
        //                }
        //
        //                if (self.users[index].id == self.user?.id) {
        //                    cell.isUserInteractionEnabled = true
        //                }
        //
        //                if (self.users[index].status != "") {
        //                    cell.statusLabel.text = self.users[index].status
        //                    if (self.users[index].status == "Accepted") {
        //                        cell.isUserInteractionEnabled = false
        //                    }
        //                }
        //            } else {
        //                cell.nameLabel.text = "Invite"
        //                cell.profilePicture.image = UIImage(named: "invite")
        //                cell.profilePicture.image = cell.profilePicture.image?.withRenderingMode(.alwaysTemplate)
        //                cell.profilePicture.tintColor = FlatGray()
        //                cell.profilePicture.contentMode = .center
        //                cell.isUserInteractionEnabled = true
        //                if (owner?.id != self.user?.id) {
        //                    cell.isUserInteractionEnabled = false
        //                }
        //
        //                cell.statusLabel.text = ""
        //            }
        //        } else {
        //            cell.nameLabel.text = "Invite"
        //            cell.profilePicture.image = UIImage(named: "invite")
        //            cell.profilePicture.image = cell.profilePicture.image?.withRenderingMode(.alwaysTemplate)
        //            cell.profilePicture.tintColor = FlatGray()
        //            cell.profilePicture.contentMode = .center
        //            cell.statusLabel.text = ""
        //            cell.isUserInteractionEnabled = true
        //            if (owner?.id != self.user?.id) {
        //                cell.isUserInteractionEnabled = false
        //            }
        //            cell.statusLabel.text = ""
        //        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.height/3.0, height: frame.height/2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.usersCollectionView.cellForItem(at: indexPath)
        // Invite the user to the group
        delegate?.invite(index: cell!.tag)
        
        
//        var userIndex = -1
//        
//        for (index, user) in self.users.enumerated() {
//            if user.id == self.user?.id && user.status != "" {
//                userIndex = index
//            }
//        }
//        
//        if (self.users.count > 0 && userIndex == (indexPath.row - 1)) {
//            
//            let appearance = SCLAlertView.SCLAppearance(
//                showCloseButton: false,
//                showCircularIcon: false
//            )
//            
//            let alertView = SCLAlertView(appearance: appearance)
//            
//            alertView.addButton("Accept", backgroundColor: FlatGreen())   {
//                self.delegate?.acceptGroupInvitation(groupIndex: cell!.tag)
//                cell?.isUserInteractionEnabled = false
//            }
//            
//            alertView.addButton("Decline", backgroundColor: FlatRed()) {
//                self.delegate?.declineGroupInvitation(groupIndex: cell!.tag)
//            }
//            
//            
//            alertView.addButton("Later") {}
//            
//            alertView.showInfo("Invitation", subTitle: "Accept Invitation")
//        } else {
//            delegate?.invite(index: cell!.tag, deal: self.deal!)
//        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 14, 0, 14)
    }
    
    func redeem(sender: UIButton) {
        let row : Int = (sender.layer.value(forKey: "row")) as! Int
        delegate?.redeem(index: row)
    }
    
    
    
}



// Horizontal collection view containing each user
class UserCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var profilePicture = UIImageView()
    var nameLabel = UILabel()
    var statusLabel = UILabel()
    
    // This view set up is for the horizontal collection view that includes each user's profile picture, name, and status
    func setupViews(){
        backgroundColor = UIColor.clear
        
        removeFromSuperview()
        addSubview(profilePicture)
        addSubview(nameLabel)
        addSubview(statusLabel)
        
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        profilePicture.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 2.0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: profilePicture.centerXAnchor).isActive = true
        nameLabel.textAlignment = .center
        nameLabel.textColor = FlatWhite()
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byClipping
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.font = UIFont.systemFont(ofSize: 11)
        nameLabel.sizeToFit()
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        statusLabel.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        statusLabel.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        statusLabel.centerXAnchor.constraint(equalTo: profilePicture.centerXAnchor).isActive = true
        
        statusLabel.textAlignment = .center
        statusLabel.textColor = FlatWhite()
        statusLabel.numberOfLines = 0
        statusLabel.font = UIFont.systemFont(ofSize: 8)
        
        profilePicture.layoutIfNeeded()
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = FlatGray().cgColor
        profilePicture.backgroundColor = UIColor.clear
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePicture.image = nil
        nameLabel.text = nil
        statusLabel.text = nil

    }
}
