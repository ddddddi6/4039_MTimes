//
//  WebViewController.swift
//  MTimes
//
//  Created by Dee on 24/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    var weblink: String?

    // display cinema homepage
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: weblink!);
        let requestObj = URLRequest(url: url!);
        webView.loadRequest(requestObj);
        webView.backgroundColor = UIColor.clear

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
