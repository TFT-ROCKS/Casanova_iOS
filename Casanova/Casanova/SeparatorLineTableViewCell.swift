//
//  SeparatorLineTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class SeparatorLineTableViewCell: UITableViewCell {

    @IBOutlet weak var separatorLine: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        separatorLine.backgroundColor = UIColor.tftCoolGrey
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
