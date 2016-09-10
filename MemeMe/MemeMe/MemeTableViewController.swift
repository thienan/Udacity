//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-09-09.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    var memes: [Meme] = []
    private let reuseIdentifier = "Meme"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            memes = appDelegate.memes
        }
        tableView.reloadData()
        
        if tabBarController?.tabBar.hidden == true {
            tabBarController?.tabBar.hidden = false
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

        // Configure the cell...
        let meme = memes[indexPath.row]
        cell.imageView?.contentMode = .ScaleAspectFill
        cell.imageView?.image = meme.memedImage
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel!.text = meme.topText

        return cell
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetailView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let detailViewController = segue.destinationViewController as! DetailViewController
                detailViewController.memeIndexToDisplay = indexPath.row
            }
        }
    }
}
