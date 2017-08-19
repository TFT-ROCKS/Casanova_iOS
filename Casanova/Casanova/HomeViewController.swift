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
    
    // Sub views
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var filterListView: TagListView!
    
    // Constraints
    @IBOutlet weak var homeTableViewBottomConstraint: NSLayoutConstraint!
    
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
        homeTableView.backgroundColor = UIColor.bgdColor
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 399
        
        // Register customized cells
        let topicBriefTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.topicBriefTableViewCell, bundle: nil)
        homeTableView.register(topicBriefTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.View.topicBriefTableViewCell)
        let loadMoreTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.loadMoreTableViewCell, bundle: nil)
        homeTableView.register(loadMoreTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.View.loadMoreTableViewCell)
        
        // Navigation bar setup
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        navigationController?.navigationBar.setBottomBorderColor(color: UIColor.bgdColor, height: 1)
        navigationController?.navigationBar.barTintColor = UIColor.bgdColor
        setTitle()
        setButtons()
        
        // Fetch topics from 0 ~ 20 (determined)
        fetchTopics(from: topics.count)
        
        // Setup filterListView
        filterListView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Nav bar config
        navigationController?.navigationBar.layer.shadowColor = UIColor.shadowColor.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        navigationController?.navigationBar.layer.shadowRadius = 3.0
        navigationController?.navigationBar.layer.shadowOpacity = 1.0
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
        
        filterListView.textFont = UIFont.mr(size: 14)
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
        let attributedString = AttrString.titleAttrString("TFTROCKS", textColor: UIColor.brandColor)
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
//        let y = (navigationController?.navigationBar.frame.origin.y)! + (navigationController?.navigationBar.frame.height)!
        filterView = FilterView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: (tabBarController?.tabBar.frame.origin.y)!))
        filterView!.setTableViewDatasourceDelegate(dataSourceDelegate: self)
        filterView!.isHidden = true
        view.addSubview(filterView!)
        view.bringSubview(toFront: filterView!)
    }
    
    func filterButtonClicked(_ sender: UIBarButtonItem) {
        
        if filterView == nil {
            setupFilterView()
        }
        
        if (filterView?.isHidden)! { // Fade In alpha 0 -> 1
            filterView?.fadeIn(withDuration: Duration.HomeVC.FilterView.fadeInOrOutDuration, withCompletionBlock: { success in
                if success {
                    // Saved current filter params
                    self.preLevels = self.levels
                    self.preTags = self.tags
                    self.filterView?.tpoTableView.reloadData()
                    self.filterView?.catgTableView.reloadData()
                    self.filterView?.levelTableView.reloadData()
                }
            })
        } else { // Fade Out alpha 1 -> 0
            filterView?.fadeOut(withDuration: Duration.HomeVC.FilterView.fadeInOrOutDuration, withCompletionBlock: { success in
                if success {
                    // if filter view hidden, compare with previous filter
                    // if diff with previous filter, then start updating
                    if self.needsUpdate() {
                        self.updateFilterListView()
                        self.updateFlag = true
                        self.fetchTopics(from: 0)
                    }
                }
            })
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

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.tag != Tags.HomeVC.homeTableViewTag { return }
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            // Hide
            toggleTabBar(true, animated: true)
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.tag != Tags.HomeVC.homeTableViewTag { return }
        if velocity.y < 0 {
            // Un-Hide
            toggleTabBar(false, animated: true)
            navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            
        }
    }
    
    func toggleTabBar(_ hidden: Bool, animated: Bool) {
        let tabBar = self.tabBarController?.tabBar
        if tabBar!.isHidden == hidden { return }
        let frame = tabBar?.frame
        let offset = (hidden ? (frame?.size.height)! : -(frame?.size.height)!)
        let duration: TimeInterval = (animated ? Double(UINavigationControllerHideShowBarDuration) : 0.0)
        tabBar?.isHidden = false
        if frame != nil {
            UIView.animate(withDuration: duration,
                           animations: {
                            tabBar!.frame = frame!.offsetBy(dx: 0, dy: offset)
            },
                           completion: {
                            if $0 {tabBar?.isHidden = hidden}
            })
        }
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
            cell.title.attributedText = AttrString.normalLabelAttrString(tpoArray[indexPath.row])
            if indexPath.row == 0 || indexPath.row == 1 {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return cell
        case Tags.HomeVC.levelTableViewTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell, for: indexPath) as! FilterTableViewCell
            cell.title.attributedText = AttrString.normalLabelAttrString(levelArray[indexPath.row])
            let level = indexPath.row + 1
            if levels.contains(String(level)) {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return cell
        case Tags.HomeVC.catTableViewTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell, for: indexPath) as! FilterTableViewCell
            cell.title.attributedText = AttrString.normalLabelAttrString(catArray[indexPath.row])
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
                whiteRoundedView.layer.backgroundColor = UIColor.bgdColor.cgColor
                whiteRoundedView.layer.masksToBounds = false
                whiteRoundedView.layer.shadowColor = UIColor.shadowColor.cgColor
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
            let vc = TopicDetailViewController(withTopic: topics[indexPath.row], withMode: .record)
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
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            break
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
