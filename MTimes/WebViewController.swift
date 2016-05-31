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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: weblink!);
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
        webView.backgroundColor = UIColor.clearColor()

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
