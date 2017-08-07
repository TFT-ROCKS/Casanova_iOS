//
//  FilterView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/6/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class FilterView: UIView, UITableViewDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tpoLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var tpoTableView: UITableView!
    @IBOutlet weak var levelTableView: UITableView!
    @IBOutlet weak var catgTableView: UITableView!
    
    override init(frame: CGRect) { // For using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // For using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        tpoLabel.font = Fonts.HomeVC.FilterView.filterLabelTextFont()
        tpoLabel.textColor = Colors.HomeVC.FilterView.filterLabelTextColor()
        tpoLabel.text = "TPO"
        
        levelLabel.font = Fonts.HomeVC.FilterView.filterLabelTextFont()
        levelLabel.textColor = Colors.HomeVC.FilterView.filterLabelTextColor()
        levelLabel.text = "LEVEL"
        
        catLabel.font = Fonts.HomeVC.FilterView.filterLabelTextFont()
        catLabel.textColor = Colors.HomeVC.FilterView.filterLabelTextColor()
        catLabel.text = "CATEGORIES"
    }

    func setTableViewDatasourceDelegate <D: UITableViewDataSource & UITableViewDelegate> (dataSourceDelegate: D) {
        // TPO table view
        tpoTableView.delegate = dataSourceDelegate
        tpoTableView.dataSource = dataSourceDelegate
        tpoTableView.tag = Tags.HomeVC.tpoTableViewTag
        let filterTableViewCell = UINib(nibName: ReuseIDs.HomeVC.FilterView.filterTableViewCell, bundle: nil)
        tpoTableView.register(filterTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell)
        tpoTableView.tableFooterView = UIView(frame: .zero)
        tpoTableView.rowHeight = UITableViewAutomaticDimension
        tpoTableView.estimatedRowHeight = 40
        
        // LEVEL table view
        levelTableView.delegate = dataSourceDelegate
        levelTableView.dataSource = dataSourceDelegate
        levelTableView.tag = Tags.HomeVC.levelTableViewTag
        levelTableView.register(filterTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell)
        levelTableView.tableFooterView = UIView(frame: .zero)
        levelTableView.rowHeight = UITableViewAutomaticDimension
        levelTableView.estimatedRowHeight = 40
        
        // CATG table view
        catgTableView.delegate = dataSourceDelegate
        catgTableView.dataSource = dataSourceDelegate
        catgTableView.tag = Tags.HomeVC.catTableViewTag
        catgTableView.register(filterTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell)
        catgTableView.tableFooterView = UIView(frame: .zero)
        catgTableView.rowHeight = UITableViewAutomaticDimension
        catgTableView.estimatedRowHeight = 40
    }
}
