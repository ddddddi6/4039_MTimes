//
//  DiscoverViewController.swift
//  MTimes
//
//  Created by Dee on 10/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var recLabel: UILabel!
    @IBOutlet var mapLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recLabel.text = "Recommendation"
        self.mapLabel.text = "Locate cinema"
        
        let buttonText = ["Search", "Popular movies", "Find a cinema"]
        var buttonArray = Array<UIButton>()
        
        var number = self.searchBar.frame.maxY + 15
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
        
        buttonArray[1].addTarget(self, action: #selector(DiscoverViewController.displayPopularMovies(_:)), forControlEvents: .TouchUpInside)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayPopularMovies (sender: UIButton!) {
        self.performSegueWithIdentifier("popularSegue", sender: nil)
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
