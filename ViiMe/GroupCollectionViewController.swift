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

class GroupCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var groups = ["a", "b"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = FlatBlack()
        self.view.backgroundColor = FlatBlack()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
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
        return groups.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionViewCell
    
        cell.cancelButton.addTarget(self, action: #selector(removeGroup(_:)), for: .touchDown)
        let user = UserInfo(username: "test", name: "Mousa", id: "", age: "", email: "", gender: "", profile: "https://firebasestorage.googleapis.com/v0/b/viime-a14cf.appspot.com/o/profile%2F%20SGY9jHnWcDaW4YnotZlbn6DXTbj2.png?alt=media&token=74ca8c00-2d0d-4272-89e5-1628432911b5")
        let user2 = UserInfo(username: "test", name: "Sunny", id: "", age: "", email: "", gender: "", profile: "https://firebasestorage.googleapis.com/v0/b/viime-a14cf.appspot.com/o/profile%2F%20wOqnHEWSw2OXRySx0gx3l4voUHj1.png?alt=media&token=30579091-e3fa-4747-89c2-a553a7350f18")
             let user3 = UserInfo(username: "test", name: "Sunny", id: "", age: "", email: "", gender: "", profile: "https://firebasestorage.googleapis.com/v0/b/viime-a14cf.appspot.com/o/profile%2F%20wOqnHEWSw2OXRySx0gx3l4voUHj1.png?alt=media&token=30579091-e3fa-4747-89c2-a553a7350f18")
             let user4 = UserInfo(username: "test", name: "Sunny", id: "", age: "", email: "", gender: "", profile: "https://firebasestorage.googleapis.com/v0/b/viime-a14cf.appspot.com/o/profile%2F%20wOqnHEWSw2OXRySx0gx3l4voUHj1.png?alt=media&token=30579091-e3fa-4747-89c2-a553a7350f18")
             let user5 = UserInfo(username: "test", name: "Sunny", id: "", age: "", email: "", gender: "", profile: "https://firebasestorage.googleapis.com/v0/b/viime-a14cf.appspot.com/o/profile%2F%20wOqnHEWSw2OXRySx0gx3l4voUHj1.png?alt=media&token=30579091-e3fa-4747-89c2-a553a7350f18")
        cell.users = [user, user2]
        cell.numOfPeople = cell.users.count + 3

        return cell
    }
    
    func removeGroup(_ button: UIButton) {
        self.groups.remove(at: 0)
        self.collectionView?.reloadData()
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
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
