//
//  GroupCollectionViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-08.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import ChameleonFramework

private let reuseIdentifier = "GroupCategoryCell"

class GroupCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserCollectionViewCellDelegate {

    var groups : Dictionary<String, Any>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = FlatBlack()
        self.view.backgroundColor = FlatBlack()
        
        let collectionViewLayout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset =  UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        collectionViewLayout?.invalidateLayout()
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
        return self.groups.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionViewCell
        cell.delegate = self
        cell.cancelButton.addTarget(self, action: #selector(removeGroup(_:)), for: .touchDown)
        
        // This should be group owner
        cell.users = []
        cell.numOfPeople = cell.users.count + 3
        
        return cell
    }
    
    func removeGroup(_ button: UIButton) {
//        self.groups.remove(at: 0)
        self.collectionView?.reloadData()
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 15 spacing from each side
        return CGSize(width: view.frame.width - 30, height: 180)
    }
    
    func invite() {
        let invitationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendsTableViewController") as! FriendsTableViewController
        self.navigationController?.pushViewController(invitationController, animated: true)
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
