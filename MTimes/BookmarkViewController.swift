//
//  BookmarkViewController.swift
//  MTimes
//
//  Created by Dee on 3/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class BookmarkViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mvc: MovieViewController = MovieViewController()
        let movies = mvc.getMovies()
        var number = self.navigationController!.navigationBar.frame.size.height + 5
        for movie in movies {
            let label = UILabel(frame: CGRectMake(15, number , 330, 62))
            label.text = movie
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.boldSystemFontOfSize(18)
            view.addSubview(label)
            number += 25
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
