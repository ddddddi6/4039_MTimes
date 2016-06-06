//
//  AboutViewController.swift
//  MTimes
//
//  Created by Dee on 6/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let m_api = UILabel(frame: CGRectMake(10, 85 , 380, 21))
        m_api.text = "The Movie Database API"
        m_api.textColor = UIColor.whiteColor()
        m_api.font = UIFont.boldSystemFontOfSize(17)
        
        let m_desc = UILabel(frame: CGRectMake(10, m_api.frame.maxY+5, 360, 42))
        m_desc.text = "https://www.themoviedb.org/documentation/api/terms-of-use"
        m_desc.lineBreakMode = NSLineBreakMode.ByWordWrapping
        m_desc.numberOfLines = 2
        m_desc.textColor = UIColor.whiteColor()
        m_desc.font = UIFont.systemFontOfSize(14)
        
        let g_api = UILabel(frame: CGRectMake(10, m_desc.frame.maxY+5, 380, 21))
        g_api.text = "Google Map API"
        g_api.textColor = UIColor.whiteColor()
        g_api.font = UIFont.boldSystemFontOfSize(17)
        
        let g_desc = UILabel(frame: CGRectMake(10, g_api.frame.maxY+5, 360, 42))
        g_desc.lineBreakMode = NSLineBreakMode.ByWordWrapping
        g_desc.numberOfLines = 2
        g_desc.text = "https://developers.google.com/places/web-service/search#PlaceSearchRequests"
        g_desc.textColor = UIColor.whiteColor()
        g_desc.font = UIFont.systemFontOfSize(14)
        
        let swiftyjson = UILabel(frame: CGRectMake(10, g_desc.frame.maxY+5, 380, 21))
        swiftyjson.text = "SwiftyJSON"
        swiftyjson.textColor = UIColor.whiteColor()
        swiftyjson.font = UIFont.boldSystemFontOfSize(17)
        
        let s_desc = UILabel(frame: CGRectMake(10, swiftyjson.frame.maxY+5, 360, 42))
        s_desc.lineBreakMode = NSLineBreakMode.ByWordWrapping
        s_desc.numberOfLines = 2
        s_desc.text = "https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE"
        s_desc.textColor = UIColor.whiteColor()
        s_desc.font = UIFont.systemFontOfSize(14)
        
        let desc = UILabel(frame: CGRectMake(10, s_desc.frame.maxY+10, 360, 42))
        desc.text = "This product uses the TMDb API but is not endorsed or certified by TMDb."
        desc.lineBreakMode = NSLineBreakMode.ByWordWrapping
        desc.numberOfLines = 2
        desc.textColor = UIColor.lightGrayColor()
        desc.font = UIFont.boldSystemFontOfSize(15)
        
        self.view.addSubview(m_api)
        self.view.addSubview(m_desc)
        self.view.addSubview(g_api)
        self.view.addSubview(g_desc)
        self.view.addSubview(swiftyjson)
        self.view.addSubview(s_desc)
        self.view.addSubview(desc)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
