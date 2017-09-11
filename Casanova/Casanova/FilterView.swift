//
//  FilterView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/6/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol FilterViewDelegate: class {
    func backButtonTappedOnFilterView()
    func doneButtonTappedOnFilterView()
    func clearButtonTappedOnFilterView()
}

class FilterView: UIView, UITableViewDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tpoLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var tpoTableView: UITableView!
    @IBOutlet weak var levelTableView: UITableView!
    @IBOutlet weak var catgTableView: UITableView!
    @IBAction func backButtonTapped(_ sender: UIButton) {
        delegate.backButtonTappedOnFilterView()
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        delegate.clearButtonTappedOnFilterView()
    }
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        delegate.doneButtonTappedOnFilterView()
    }
    
    weak var delegate: FilterViewDelegate!
    
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
        
        tpoLabel.attributedText = AttrString.normalLabelAttrString("TPO")
        levelLabel.attributedText = AttrString.normalLabelAttrString("难度")
        catLabel.attributedText = AttrString.normalLabelAttrString("分类")
        
        titleLabel.font = UIFont.pfl(size: 17)
        titleLabel.textColor = UIColor.tftCoolGrey
        titleLabel.text = "筛选"
        
        clearButton.setTitle("清除", for: .normal)
        clearButton.setTitleColor(UIColor.tftCoolGrey, for: .normal)
        clearButton.titleLabel?.font = UIFont.pfl(size: 17)
        
        doneButton.setTitle("确认", for: .normal)
        doneButton.setTitleColor(UIColor.brandColor, for: .normal)
        doneButton.titleLabel?.font = UIFont.pfl(size: 17)
        
        doneButton.layer.cornerRadius = doneButton.bounds.height / 2
        doneButton.layer.masksToBounds = true
        doneButton.layer.borderColor = UIColor.brandColor.cgColor
        doneButton.layer.borderWidth = 2
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
