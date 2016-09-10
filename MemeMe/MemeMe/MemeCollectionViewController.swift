//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-09-09.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    private var memes: [Meme] = []
    private let reuseIdentifier = "Meme"

    override func viewWillAppear(animated: Bool) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            memes = appDelegate.memes
        }
        collectionView?.reloadData()
        
        if tabBarController?.tabBar.hidden == true {
            tabBarController?.tabBar.hidden = false
        }
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetailView" {
            if let indexPaths = collectionView?.indexPathsForSelectedItems() {
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.memeIndexToDisplay = indexPaths[0].row
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
    
        // Configure the cell
        let meme = memes[indexPath.row]
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
