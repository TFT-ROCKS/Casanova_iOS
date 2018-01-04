//
//  ProfileSettingsTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/28/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class ProfileSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        titleLabel.textColor = UIColor.tftFadedBlue
        titleLabel.font = UIFont.pfr(size: 16)
        textField.textColor = UIColor.tftCharcoalGrey
        textField.font = UIFont.sfps(size: 17)
        textField.borderStyle = .none
    }
}
