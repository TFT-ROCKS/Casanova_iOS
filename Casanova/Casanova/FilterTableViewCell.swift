//
//  FilterTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/6/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: UIView!
    @IBOutlet weak var title: UILabel!
    
    var checked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Checkbox config
        checkBox.layer.borderWidth = 1
        checkBox.layer.cornerRadius = 2
        checkBox.layer.masksToBounds = true
        checkBox.layer.borderColor = Colors.HomeVC.FilterView.filterCheckboxColor().cgColor
        // Title label config
        title.font = Fonts.HomeVC.FilterView.filterSelectionTextFont()
        title.textColor = Colors.HomeVC.FilterView.filterSelectionTextColor()
    }
}
