//
//  AnswerBriefTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/30/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class AnswerBriefTableViewCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var answererNameLabel: UILabel!
    @IBOutlet weak var answerTimeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numOfLikesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
