//
//  DiscoverViewController.swift
//  MTimes
//
//  Created by Dee on 10/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var recLabel: UILabel!
    @IBOutlet var mapLabel: UILabel!
    @IBOutlet var bookmarkLabel: UILabel!
    @IBOutlet var aboutLabel: UILabel!
    
    var buttonArray = Array<UIButton>()
    var movieTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subView in searchBar.subviews
        {
            for subView1 in subView.subviews
            {
                if subView1.isKindOfClass(UITextField)
                {
                    subView1.backgroundColor = UIColor.clearColor()
                    subView1.layer.borderColor = UIColor.lightGrayColor().CGColor
                    subView1.layer.borderWidth = 1
                    subView1.layer.cornerRadius = 5.0
                    subView1.clipsToBounds = true
                }
            }
        }
        
        searchBar.delegate = self
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        self.recLabel.text = " Recommendation"
        self.mapLabel.text = " Locate cinema"
        self.bookmarkLabel.text = " Bookmark"
        self.aboutLabel.text = " About MTimes"
        
        let buttonText = ["Popular movies", "Find a cinema", "Bookmark", "About"]
        
        var number = self.searchBar.frame.maxY + 47
        for i in 0 ..< buttonText.count
        {
            let button = UIButton(frame: CGRectMake(100, number, 150, 28))
            button.center.x = self.view.center.x
            button.backgroundColor = UIColor.grayColor()
            button.layer.cornerRadius = 5.0
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
            button.setTitle(buttonText[i], forState: UIControlState.Normal)
            buttonArray.append(button)
            self.view.addSubview(button)
            number += 88
        }
        
        buttonArray[0].addTarget(self, action: #selector(DiscoverViewController.displayPopularMovies(_:)), forControlEvents: .TouchUpInside)
        
        buttonArray[1].addTarget(self, action: #selector(DiscoverViewController.showMap(_:)), forControlEvents: .TouchUpInside)
        
        buttonArray[2].addTarget(self, action: #selector(DiscoverViewController.displayBookmark(_:)), forControlEvents: .TouchUpInside)
        
        buttonArray[3].addTarget(self, action: #selector(DiscoverViewController.displayAboutScreen(_:)), forControlEvents: .TouchUpInside)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // jump to popular movie screen
    func displayPopularMovies (sender: UIButton!) {
        self.performSegueWithIdentifier("PopularSegue", sender: nil)
    }
    
    // jump to bookmark screen
    func displayBookmark (sender: UIButton!) {
        self.performSegueWithIdentifier("ShowBookmarkSegue", sender: nil)
    }
    
    //jump to about screen
    func displayAboutScreen (sender: UIButton!) {
        self.performSegueWithIdentifier("AboutSegue", sender: nil)
    }
    
    // jump to search result screen
    func searchBarSearchButtonClicked(searchBar: UISearchBar!)
    {
        movieTitle = searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.performSegueWithIdentifier("SearchSegue", sender: nil)
    }
    
    // jump to map screen
    func showMap (sender: UIButton!) {
        self.performSegueWithIdentifier("ShowMapSegue", sender: nil)
    }
    
    // dismiss keyboard for search bar
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // pass movie title to second view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchSegue"
        {
            if(movieTitle == "")
            {
                let messageString: String = "Please input valid movie title"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                    UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            } else {
                let controller: SearchTableController = segue.destinationViewController as! SearchTableController
                controller.movieTitle = movieTitle
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
