//
//  HomeViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBOutlet weak var filterListView: TagListView!
    // Filter view data
    let tpoArray = ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5", "Task 6"]
    let catArray = ["Education", "Culture", "Family", "Job", "Activity", "Technology", "Places", "Environment", "Others"]
    let levelArray = ["Beginner", "Easy", "Medium", "Hard", "Ridiculous"]
    // Filter params
    var levels: [String] = []
    var tags: [String] = []
    var query: String = ""
    // Previous filter params
    var preLevels: [String] = []
    var preTags: [String] = []
    var preQuery: String = ""
    // Update flag
    var updateFlag = false
    
    // Table View Data
    var topics: [Topic] = [] {
        didSet {
            homeTableView.reloadData()
        }
    }
    
    // Subviews
    var filterView: FilterView?
    
    // Constants
    let cellVerticalSpace: CGFloat = 15
    let cellHorizontalSpace: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view setup
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.tag = Tags.HomeVC.homeTableViewTag
        homeTableView.contentInset = UIEdgeInsets.zero
        
        //        homeTableView.allowsSelection = false
        homeTableView.backgroundColor = UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1)
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 399
        
        // Register customized cells
        let topicBriefTableViewCell = UINib(nibName: "TopicBriefTableViewCell", bundle: nil)
        homeTableView.register(topicBriefTableViewCell, forCellReuseIdentifier: "TopicBriefTableViewCell")
        let loadMoreTableViewCell = UINib(nibName: "LoadMoreTableViewCell", bundle: nil)
        homeTableView.register(loadMoreTableViewCell, forCellReuseIdentifier: "LoadMoreTableViewCell")
        
        // Navigation bar setup
        navigationController?.navigationBar.tintColor = UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1)
        navigationController?.navigationBar.setBottomBorderColor(color: UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1), height: 1)
        navigationController?.navigationBar.barTintColor = UIColor.white
        setTitle()
        setButtons()
        
        // Fetch topics from 0 ~ 20 (determined)
        fetchTopics(from: topics.count)
        
        // Setup filterListView
        filterListView.delegate = self
    }
    
    func fetchTopics(from: Int) {
        // Fetch topics
        TopicManager.shared.fetchTopics(levels: levels, query: query, tags: tags, start: from, withCompletion: { (error, topics) in
            if error == nil {
                // success
                if self.updateFlag {
                    self.topics = topics!
                    self.updateFlag = false
                } else {
                    self.topics.append(contentsOf: topics!)
                }
            } else {
                // error found
            }
        })
    }
    
    func updateLevels(level: Int) {
        
        if let index = levels.index(of: String(level)) {
            levels.remove(at: index)
        } else {
            levels.append(String(level))
        }
        
    }
    
    func updateTags(tag: String) {
        
        if let index = tags.index(of: tag) {
            tags.remove(at: index)
        } else {
            tags.append(tag)
        }
    }
}

// MARK: - TagListViewDelegate
extension HomeViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTag(title)
        if levelArray.toLowerCase().contains(title.lowercased()) {
            updateLevels(level: levelArray.toLowerCase().index(of: title.lowercased())! + 1)
        }
        if catArray.toLowerCase().contains(title.lowercased()) {
            updateTags(tag: title.lowercased())
        }
        updateFlag = true
        fetchTopics(from: 0)
    }
    
    func updateFilterListView() {
        filterListView.removeAllTags()
        filterListView.addTags(levelsName(fromNumber: levels).toUpperCase())
        filterListView.addTags(tags.toUpperCase())
        
        filterListView.textFont = Fonts.CommonVC.TagListView.tagLabelTextFont()
    }
    
    func levelsName(fromNumber levels: [String]) -> [String] {
        var res: [String] = []
        for level in levels {
            res.append(levelArray[Int(level)! - 1])
        }
        return res
    }
}

// MARK: - Navigation Bar Items
extension HomeViewController {
    func setTitle() {
        let attributedString = NSMutableAttributedString(string: "TFTROCKS", attributes: [
            NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 18.0)!,
            NSForegroundColorAttributeName: UIColor(red: 75.0 / 255.0, green: 205.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0),
            NSKernAttributeName: -1.6
            ])
        attributedString.addAttribute(NSKernAttributeName, value: 0.0, range: NSRange(location: 7, length: 1))
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 11, width: 184, height: 22))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.attributedText = attributedString
        titleLabel.sizeToFit()
        tabBarController?.navigationItem.titleView = titleLabel
    }
    
    func setButtons() {
        let filterButton = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(filterButtonClicked(_:)))
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .plain, target: self, action: #selector(searchButtonClicked(_:)))
        tabBarController?.navigationItem.leftBarButtonItem = filterButton
        tabBarController?.navigationItem.rightBarButtonItem = searchButton
    }
    
    func setupFilterView() {
        let y = (navigationController?.navigationBar.frame.origin.y)! + (navigationController?.navigationBar.frame.height)!
        filterView = FilterView(frame: CGRect(x: 0, y: y, width: view.bounds.width, height: (tabBarController?.tabBar.frame.origin.y)! - y))
        filterView!.setTableViewDatasourceDelegate(dataSourceDelegate: self)
        view.addSubview(filterView!)
        view.bringSubview(toFront: filterView!)
    }
    
    func filterButtonClicked(_ sender: UIBarButtonItem) {
        
        if filterView == nil {
            setupFilterView()
        } else {
            filterView!.isHidden = !filterView!.isHidden
            // if filter view hidden, compare with previous filter
            // if diff with previous filter, then start updating
            if filterView!.isHidden && needsUpdate() {
                updateFilterListView()
                updateFlag = true
                fetchTopics(from: 0)
            } else {
                // Saved current filter params
                preLevels = levels
                preTags = tags
                filterView?.tpoTableView.reloadData()
                filterView?.catgTableView.reloadData()
                filterView?.levelTableView.reloadData()
            }
        }
    }
    
    func searchButtonClicked(_ sender: UIBarButtonItem) {
        
    }
    
    func needsUpdate() -> Bool {
        if preLevels.count != levels.count || preTags.count != tags.count {
            // Needs update
            return true
        } else {
            for preLevel in preLevels {
                if !levels.contains(preLevel) {
                    // Needs update
                    return true
                }
            }
            for preTag in preTags {
                if !tags.contains(preTag) {
                    // Needs update
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - TableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            switch section {
            case 0:
                return topics.count
            case 1:
                return 1
            default:
                return 0
            }
        case Tags.HomeVC.tpoTableViewTag:
            return tpoArray.count
        case Tags.HomeVC.levelTableViewTag:
            return levelArray.count
        case Tags.HomeVC.catTableViewTag:
            return catArray.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            // Hide "Load More" Button if there is no topics present
            if topics.count > 0 {
                return 2
            } else {
                return 1
            }
        case Tags.HomeVC.tpoTableViewTag:
            return 1
        case Tags.HomeVC.levelTableViewTag:
            return 1
        case Tags.HomeVC.catTableViewTag:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopicBriefTableViewCell", for: indexPath) as! TopicBriefTableViewCell
                cell.topic = topics[indexPath.row]
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTableViewCell", for: indexPath) as! LoadMoreTableViewCell
                cell.delegate = self
                return cell
            default:
                return UITableViewCell()
            }
        case Tags.HomeVC.tpoTableViewTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell, for: indexPath) as! FilterTableViewCell
            cell.title.text = tpoArray[indexPath.row]
            if indexPath.row == 0 || indexPath.row == 1 {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return cell
        case Tags.HomeVC.levelTableViewTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell, for: indexPath) as! FilterTableViewCell
            cell.title.text = levelArray[indexPath.row]
            let level = indexPath.row + 1
            if levels.contains(String(level)) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return cell
        case Tags.HomeVC.catTableViewTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell, for: indexPath) as! FilterTableViewCell
            cell.title.text = catArray[indexPath.row]
            let tag = catArray[indexPath.row]
            if tags.toUpperCase().contains(tag.uppercased()) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            if let cell = cell as? TopicBriefTableViewCell {
                
                // Visualize the margin surrounding the table view cell
                cell.contentView.backgroundColor = UIColor.clear
                cell.backgroundColor = UIColor.clear
                
                // remove small whiteRoundedView before adding new one
                for view in cell.contentView.subviews {
                    if view.tag == 100 {
                        view.removeFromSuperview()
                    }
                }
                
                let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: cellVerticalSpace / 2, width: self.view.bounds.width, height: cell.bounds.height - cellVerticalSpace / 2))
                whiteRoundedView.tag = 100
                whiteRoundedView.layer.backgroundColor = UIColor.white.cgColor
                //            whiteRoundedView.layer.masksToBounds = false
                //            whiteRoundedView.layer.cornerRadius = 5
                whiteRoundedView.layer.shadowColor = UIColor(red: 217/255.0, green: 225/255.0, blue: 239/255.0, alpha: 1).cgColor
                whiteRoundedView.layer.shadowOffset = CGSize(width: 0, height: 1)
                whiteRoundedView.layer.shadowOpacity = 1
                
                cell.contentView.addSubview(whiteRoundedView)
                cell.contentView.sendSubview(toBack: whiteRoundedView)
                
            } else if let cell = cell as? LoadMoreTableViewCell {
                
                // Visualize the margin surrounding the table view cell
                cell.contentView.backgroundColor = UIColor.clear
                cell.backgroundColor = UIColor.clear
                
            }
        case Tags.HomeVC.tpoTableViewTag:
            break
        case Tags.HomeVC.levelTableViewTag:
            break
        case Tags.HomeVC.catTableViewTag:
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            let vc = TopicDetailViewController(withTopic: topics[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        case Tags.HomeVC.tpoTableViewTag:
            break
        case Tags.HomeVC.levelTableViewTag:
            let level = indexPath.row + 1
            updateLevels(level: level)
            break
        case Tags.HomeVC.catTableViewTag:
            let tag = catArray[indexPath.row]
            updateTags(tag: tag.lowercased())
            break
        default:
            break
        }
    }
}

// MARK: - LoadMoreTableViewCellDelegate

extension HomeViewController: LoadMoreTableViewCellDelegate {
    func loadMoreButtonClicked() {
        // Do load more function
        fetchTopics(from: topics.count)
    }
}

// MARK: - Navigation appearance extension
// ref: https://stackoverflow.com/questions/19101361/ios7-change-uinavigationbar-border-color

extension UINavigationBar {
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
}

// MARK: - String Array to uppercase

extension Array {
    func toUpperCase() -> [String] {
        var res: [String] = []
        for str in self {
            if let s = str as? String {
                res.append(s.uppercased())
            }
        }
        return res
    }
    
    func toLowerCase() -> [String] {
        var res: [String] = []
        for str in self {
            if let s = str as? String {
                res.append(s.lowercased())
            }
        }
        return res
    }
}
