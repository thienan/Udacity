//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-09-09.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var memes: [Meme] = []
    var memeIndexToDisplay: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.hidden = true
        navigationItem.rightBarButtonItem = editButtonItem()
        
        // Do any additional setup after loading the view.
        if let index = memeIndexToDisplay {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                memes = appDelegate.memes
            }
            imageView?.image = memes[index].memedImage
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let index = memeIndexToDisplay {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                memes = appDelegate.memes
            }
            imageView?.image = memes[index].memedImage
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        performSegueWithIdentifier("EditMeme", sender: nil)
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditMeme" {
            let homeViewController = segue.destinationViewController as! HomeViewController
            
            if let index = memeIndexToDisplay {
                homeViewController.memeIndexToEdit = index
            }
        }
    }
}
