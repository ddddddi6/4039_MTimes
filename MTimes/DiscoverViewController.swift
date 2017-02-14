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
                if subView1.isKind(of: UITextField.self)
                {
                    subView1.backgroundColor = UIColor.clear
                    subView1.layer.borderColor = UIColor.lightGray.cgColor
                    subView1.layer.borderWidth = 1
                    subView1.layer.cornerRadius = 5.0
                    subView1.clipsToBounds = true
                }
            }
        }
        
        searchBar.delegate = self
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        self.recLabel.text = " Recommendation"
        self.mapLabel.text = " Locate cinema"
        self.bookmarkLabel.text = " Bookmark"
        self.aboutLabel.text = " About MTimes"
        
        let buttonText = ["Popular movies", "Find a cinema", "Bookmark", "About"]
        
        var number = self.searchBar.frame.maxY + 47
        for i in 0 ..< buttonText.count
        {
            let button = UIButton(frame: CGRect(x: 100, y: number, width: 150, height: 28))
            button.center.x = self.view.center.x
            button.backgroundColor = UIColor.gray
            button.layer.cornerRadius = 5.0
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.setTitle(buttonText[i], for: UIControlState())
            buttonArray.append(button)
            self.view.addSubview(button)
            number += 88
        }
        
        buttonArray[0].addTarget(self, action: #selector(DiscoverViewController.displayPopularMovies(_:)), for: .touchUpInside)
        
        buttonArray[1].addTarget(self, action: #selector(DiscoverViewController.showMap(_:)), for: .touchUpInside)
        
        buttonArray[2].addTarget(self, action: #selector(DiscoverViewController.displayBookmark(_:)), for: .touchUpInside)
        
        buttonArray[3].addTarget(self, action: #selector(DiscoverViewController.displayAboutScreen(_:)), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // jump to popular movie screen
    func displayPopularMovies (_ sender: UIButton!) {
        self.performSegue(withIdentifier: "PopularSegue", sender: nil)
    }
    
    // jump to bookmark screen
    func displayBookmark (_ sender: UIButton!) {
        self.performSegue(withIdentifier: "ShowBookmarkSegue", sender: nil)
    }
    
    //jump to about screen
    func displayAboutScreen (_ sender: UIButton!) {
        self.performSegue(withIdentifier: "AboutSegue", sender: nil)
    }
    
    // jump to search result screen
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar!)
    {
        movieTitle = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        self.performSegue(withIdentifier: "SearchSegue", sender: nil)
    }
    
    // jump to map screen
    func showMap (_ sender: UIButton!) {
        self.performSegue(withIdentifier: "ShowMapSegue", sender: nil)
    }
    
    // dismiss keyboard for search bar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // pass movie title to second view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegue"
        {
            if(movieTitle == "")
            {
                let messageString: String = "Please input valid movie title"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                    UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                let controller: SearchTableController = segue.destination as! SearchTableController
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
