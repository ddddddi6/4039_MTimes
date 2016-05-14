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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

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
        
        var textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        self.recLabel.text = "Recommendation"
        self.mapLabel.text = "Locate cinema"
        
        let buttonText = ["Popular movies", "Find a cinema"]
        var buttonArray = Array<UIButton>()
        
        var number = self.searchBar.frame.maxY + 47
        for var i = 0; i < buttonText.count; i++
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayPopularMovies (sender: UIButton!) {
        self.performSegueWithIdentifier("popularSegue", sender: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!)
    {
        self.performSegueWithIdentifier("SearchSegue", sender: nil)
            
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchSegue"
        {
            let controller: SearchTableController = segue.destinationViewController as! SearchTableController
            
            let title = searchBar.text
            
            controller.movieTitle = title
            // Display movie details screen
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
