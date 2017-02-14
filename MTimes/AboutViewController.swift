//
//  AboutViewController.swift
//  MTimes
//
//  Created by Dee on 6/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Labels for displaying infomation related to this application
        let apiLabel = UILabel(frame: CGRect(x: 10, y: 85 , width: 380, height: 21))
        apiLabel.text = "The Movie Database API"
        apiLabel.textColor = UIColor.white
        apiLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        let descLabel = UILabel(frame: CGRect(x: 10, y: apiLabel.frame.maxY+5, width: 360, height: 42))
        descLabel.text = "https://www.themoviedb.org/documentation/api/terms-of-use"
        descLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        descLabel.numberOfLines = 2
        descLabel.textColor = UIColor.white
        descLabel.font = UIFont.systemFont(ofSize: 14)
        
        let googleApi = UILabel(frame: CGRect(x: 10, y: descLabel.frame.maxY+5, width: 380, height: 21))
        googleApi.text = "Google Map API"
        googleApi.textColor = UIColor.white
        googleApi.font = UIFont.boldSystemFont(ofSize: 17)
        
        let googleDesc = UILabel(frame: CGRect(x: 10, y: googleApi.frame.maxY+5, width: 360, height: 42))
        googleDesc.lineBreakMode = NSLineBreakMode.byWordWrapping
        googleDesc.numberOfLines = 2
        googleDesc.text = "https://developers.google.com/places/web-service/search#PlaceSearchRequests"
        googleDesc.textColor = UIColor.white
        googleDesc.font = UIFont.systemFont(ofSize: 14)
        
        let swiftyJson = UILabel(frame: CGRect(x: 10, y: googleDesc.frame.maxY+5, width: 380, height: 21))
        swiftyJson.text = "SwiftyJSON"
        swiftyJson.textColor = UIColor.white
        swiftyJson.font = UIFont.boldSystemFont(ofSize: 17)
        
        let swiftyJsonDesc = UILabel(frame: CGRect(x: 10, y: swiftyJson.frame.maxY+5, width: 360, height: 42))
        swiftyJsonDesc.lineBreakMode = NSLineBreakMode.byWordWrapping
        swiftyJsonDesc.numberOfLines = 2
        swiftyJsonDesc.text = "https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE"
        swiftyJsonDesc.textColor = UIColor.white
        swiftyJsonDesc.font = UIFont.systemFont(ofSize: 14)
        
        let desc = UILabel(frame: CGRect(x: 10, y: swiftyJsonDesc.frame.maxY+10, width: 360, height: 42))
        desc.text = "This product uses the TMDb API but is not endorsed or certified by TMDb."
        desc.lineBreakMode = NSLineBreakMode.byWordWrapping
        desc.numberOfLines = 2
        desc.textColor = UIColor.lightGray
        desc.font = UIFont.boldSystemFont(ofSize: 15)
        
        // Add labels to the view
        self.view.addSubview(apiLabel)
        self.view.addSubview(descLabel)
        self.view.addSubview(googleApi)
        self.view.addSubview(googleDesc)
        self.view.addSubview(swiftyJson)
        self.view.addSubview(swiftyJsonDesc)
        self.view.addSubview(desc)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
