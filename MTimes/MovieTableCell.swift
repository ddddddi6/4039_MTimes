//
//  MovieTableCell.swift
//  MTimes
//
//  Created by Dee on 27/04/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class MovieTableCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var popularityLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var posterView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
