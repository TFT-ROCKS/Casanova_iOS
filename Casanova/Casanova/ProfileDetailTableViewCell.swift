//
//  ProfileDetailTableViewCell.swift
//  Casanova
//
//  Created by Michael Guo on 2/6/19.
//  Copyright © 2019 Xiaoyu Guo. All rights reserved.
//

import UIKit

class ProfileDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.shadowColor.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        leftImageView.layer.cornerRadius = leftImageView.bounds.width / 2
        leftImageView.layer.masksToBounds = true
        leftImageView.contentMode = .scaleAspectFit
        
        topTitleLabel.font = UIFont.pfr(size: 16)
        topTitleLabel.textColor = UIColor.tftBlack
        
        bottomTitleLabel.font = UIFont.pfr(size: 12)
        bottomTitleLabel.textColor = UIColor.tftCoolGrey
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        leftImageView.image = nil
        topTitleLabel.text = nil
        bottomTitleLabel.text = nil
    }
}
