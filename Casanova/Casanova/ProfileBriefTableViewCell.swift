//
//  ProfileBriefTableViewCell.swift
//  Casanova
//
//  Created by Michael Guo on 2/6/19.
//  Copyright © 2019 Xiaoyu Guo. All rights reserved.
//

import UIKit

class ProfileBriefTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.shadowColor.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        titleLabel.font = UIFont.pfr(size: 15)
        titleLabel.textColor = UIColor.tftBlack
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
    
}
