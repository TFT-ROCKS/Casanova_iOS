//
//  ProfileSettingsTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/28/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class ProfileSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.shadowColor.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        titleLabel.textColor = UIColor.tftBlack
        titleLabel.font = UIFont.pfr(size: 15)
        
        textField.textColor = UIColor.tftCoolGrey
        textField.font = UIFont.sfps(size: 12)
        textField.borderStyle = .none
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        textField.text = nil
    }
}
