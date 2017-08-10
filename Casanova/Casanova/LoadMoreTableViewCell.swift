//
//  LoadMoreTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/23/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol LoadMoreTableViewCellDelegate: class {
    func loadMoreButtonClicked()
}

class LoadMoreTableViewCell: UITableViewCell {

    @IBOutlet weak var loadMoreButton: UIButton!
    @IBAction func loadMoreButtonClicked(_ sender: UIButton) {
        delegate.loadMoreButtonClicked()
    }
    
    weak var delegate: LoadMoreTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        // Add shadow to LoadMore button
        // ref: https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-shadow-to-a-uiview
        
        loadMoreButton.layer.shadowColor = UIColor(red: 217 / 255.0, green: 225 / 255.0, blue: 239 / 255.0, alpha: 1).cgColor
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
