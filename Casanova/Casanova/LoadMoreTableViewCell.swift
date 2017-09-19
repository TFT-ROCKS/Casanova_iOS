//
//  LoadMoreTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/23/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol LoadMoreTableViewCellDelegate: class {
    func loadMoreButtonClicked(_ sender: UIButton)
}

class LoadMoreTableViewCell: UITableViewCell {

    @IBOutlet weak var loadMoreButton: UIButton!
    @IBAction func loadMoreButtonClicked(_ sender: UIButton) {
        delegate.loadMoreButtonClicked(sender)
    }
    
    weak var delegate: LoadMoreTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadMoreButton.setTitleColor(UIColor.brandColor, for: .normal)
        loadMoreButton.backgroundColor = UIColor.tftDuckEggBlue
        
        selectionStyle = .none
        
        // Add shadow to LoadMore button
        // ref: https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-shadow-to-a-uiview
        
        loadMoreButton.layer.shadowColor = UIColor.shadowColor.cgColor
        loadMoreButton.layer.shadowOpacity = 1
        loadMoreButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        loadMoreButton.layer.shadowRadius = 2
        loadMoreButton.layer.shadowPath = UIBezierPath(rect: loadMoreButton.bounds).cgPath
        loadMoreButton.layer.shouldRasterize = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
