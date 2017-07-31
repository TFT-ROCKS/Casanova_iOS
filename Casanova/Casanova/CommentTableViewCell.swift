//
//  CommentTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/17/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    var comment: Comment! {
        didSet {
//            self.detailTextLabel?.text = stringFromTimeInterval(comment.timestamp)
//            self.textLabel?.text = comment.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        
        let ti = Int(interval)
        
        let ms = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }

}
