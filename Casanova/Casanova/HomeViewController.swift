//
//  HomeViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView
import NVActivityIndicatorView
import Firebase

class HomeViewController: UIViewController {
    
    // Sub views
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var filterListView: TagListView!
    let activityIndicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .audioEqualizer, color: .brandColor)
    
    // Constraints
    @IBOutlet weak var homeTableViewBottomConstraint: NSLayoutConstraint!
    
    // status bar
    var statusBarShouldBeHidden = false
    
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
    var isFetching: Bool = false
    
    // Subviews
    var filterView: FilterView?
    var searchBox: UITextField!
    
    var isSearchMode: Bool = false
    var needsShowSearchBox: Bool {
        get {
            if isSearchMode {
                if query.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
                    isSearchMode = false
                    searchBox.text = ""
                    return false
                }
                else {
                    return true
                }
            } else {
                return false
            }
        }
    }
    
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
        homeTableView.backgroundColor = UIColor.bgdColor
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 399
        
        // Activity Indicator View
        view.addSubview(activityIndicatorView)
        view.bringSubview(toFront: activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalTo: activityIndicatorView.widthAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Register customized cells
        let topicBriefTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.topicBriefTableViewCell, bundle: nil)
        homeTableView.register(topicBriefTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.View.topicBriefTableViewCell)
        let loadMoreTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.loadMoreTableViewCell, bundle: nil)
        homeTableView.register(loadMoreTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.View.loadMoreTableViewCell)
        
        // Fetch topics from 0 ~ 20 (determined)
        fetchTopics(from: topics.count)
        
        // Setup filterListView
        filterListView.delegate = self
        
        // nav items
        setSearchBox()
        
        navigationController?.navigationBar.topItem?.title = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        needsShowSearchBox ? showSearchBox() : showTitle()
        setButtons()
        
        // Nav bar config
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        Analytics.setScreenName("home", screenClass: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBox.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFetching {
            activityIndicatorView.startAnimating()
        }
        
        ViewControllerManager.shared.performActions()
    }
    
    func fetchTopics(from: Int) {
        if levels.count > 0 || query.count > 0 || tags.count > 0 {
            searchTopics()
        } else {
            isFetching = true
            // Start activity indicator animation
            activityIndicatorView.startAnimating()
            // Fetch topics
            TopicAPIService.shared.fetchTopics(num: 20, offset: from, id: nil, withCompletion:
                { (error, topics) in
                    self.isFetching = false
                    self.activityIndicatorView.stopAnimating()
                    if error == nil {
                        // shuffle topics
                        var topicsVar = topics!
                        topicsVar.shuffle()
                        // success
                        if self.updateFlag {
                            self.topics = topicsVar
                            self.updateFlag = false
                        } else {
                            self.topics.append(contentsOf: topicsVar)
                        }
                    } else {
                        // error found
                    }
            })
        }
    }
    
    func searchTopics() {
        isFetching = true
        // Start activity indicator animation
        activityIndicatorView.startAnimating()
        // Fetch topics
        TopicAPIService.shared.fetchTopics(levels: levels, query: query, tags: tags, withCompletion: { (error, topics) in
            self.isFetching = false
            self.activityIndicatorView.stopAnimating()
            if error == nil {
                // shuffle topics
                var topicsVar = topics!
                topicsVar.shuffle()
                // success
                if self.updateFlag {
                    self.topics = topicsVar
                    self.updateFlag = false
                } else {
                    self.topics.append(contentsOf: topicsVar)
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
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func setStatusBar(hidden: Bool) {
        // Hide the status bar
        statusBarShouldBeHidden = hidden
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
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
        
        filterListView.textFont = UIFont.sfps(size: 14)
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
    func showTitle() {
        tabBarController?.navigationItem.titleView = nil
        tabBarController?.navigationItem.title = "语料库"
    }
    
    func showSearchBox() {
        tabBarController?.navigationItem.titleView = searchBox
    }
    
    func setButtons() {
        let filterButton = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(filterButtonClicked(_:)))
        let searchButton = UIBarButtonItem(image: needsShowSearchBox ? nil : #imageLiteral(resourceName: "search"), style: .plain, target: self, action: #selector(searchButtonClicked(_:)))
        if needsShowSearchBox {
            searchButton.title = "取消"
        }
        
        tabBarController?.navigationItem.rightBarButtonItems = [filterButton, searchButton]
    }
}

extension HomeViewController: UITextFieldDelegate {
    func searchButtonClicked(_ sender: UIBarButtonItem) {
        if !isSearchMode {
            isSearchMode = true
            showSearchBox()
            searchBox.becomeFirstResponder()
            // change appearance
            sender.image = nil
            sender.title = "取消"
        } else {
            // end search
            searchBox.resignFirstResponder()
            if query != "" {
                query = ""
                updateFlag = true
                fetchTopics(from: 0)
            }
            searchBox.text = ""
            isSearchMode = false
            showTitle()
            // change back
            sender.image = #imageLiteral(resourceName: "search")
            sender.title = ""
        }
    }
    
    func setSearchBox() {
        searchBox = UITextField(frame: CGRect(x: view.bounds.width * (1 - 0.66) / 2, y: ((navigationController?.navigationBar.bounds.height)! - 34.0) / 2.0, width: view.bounds.width * 0.66, height: 34.0))
        searchBox.placeholder = "搜索话题"
        searchBox.layer.cornerRadius = 5
        searchBox.layer.masksToBounds = true
        searchBox.font = UIFont.pfr(size: 14)
        searchBox.textColor = UIColor.tftCoolGrey
        searchBox.backgroundColor = UIColor.bgdColor
        searchBox.returnKeyType = .search
        searchBox.delegate = self
        searchBox.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: searchBox.frame.height))
        searchBox.leftView = paddingView
        searchBox.leftViewMode = .always
        let searchIconView = UIImageView(frame: CGRect(x: 10, y: 7, width: 20, height: 20))
        searchIconView.image = #imageLiteral(resourceName: "search-h")
        searchIconView.contentMode = .scaleAspectFit
        paddingView.addSubview(searchIconView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        query = (textField.text?.replacingOccurrences(of: "\\s+", with: "+", options: .regularExpression))!
        updateFlag = true
        fetchTopics(from: 0)
        return true
    }
}

// MARK: - FilterViewDelegate
extension HomeViewController: FilterViewDelegate {
    
    func setupFilterView() {
        filterView = FilterView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: UIScreen.main.bounds.height))
        filterView!.setTableViewDatasourceDelegate(dataSourceDelegate: self)
        filterView!.isHidden = true
        filterView?.delegate = self
        view.addSubview(filterView!)
        view.bringSubview(toFront: filterView!)
    }
    
    func filterButtonClicked(_ sender: UIBarButtonItem) {
        
        if filterView == nil {
            setupFilterView()
        }
        // Fade In alpha 0 -> 1
        beforeShowFilterView()
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
    
    func beforeShowFilterView() {
        tabBarController?.tabBar.fadeOut(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration))
        navigationController?.setNavigationBarHidden(true, animated: true)
        setStatusBar(hidden: true)
    }
    
    func afterDismissFilterView() {
        tabBarController?.tabBar.fadeIn(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration))
        navigationController?.setNavigationBarHidden(false, animated: true)
        setStatusBar(hidden: false)
    }
    
    func backButtonTappedOnFilterView() {
        afterDismissFilterView()
        tags = preTags
        levels = preLevels
        filterView?.fadeOut(withDuration: Duration.HomeVC.FilterView.fadeInOrOutDuration)
    }
    
    func clearButtonTappedOnFilterView() {
        tags = []
        levels = []
        // reload table views
        filterView?.tpoTableView.reloadData()
        filterView?.catgTableView.reloadData()
        filterView?.levelTableView.reloadData()
    }
    
    func doneButtonTappedOnFilterView() {
        afterDismissFilterView()
        // Fade Out alpha 1 -> 0
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

// MARK: - TableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            return 1
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
                return topics.count + 1
            } else {
                return topics.count
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
            if indexPath.section < topics.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.View.topicBriefTableViewCell, for: indexPath) as! TopicBriefTableViewCell
                cell.topic = topics[indexPath.section]
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.View.loadMoreTableViewCell, for: indexPath) as! LoadMoreTableViewCell
                cell.delegate = self
                cell.loadMoreButton.setTitle("LOAD MORE", for: .normal)
                return cell
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
            if let cell = cell as? LoadMoreTableViewCell {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 12))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case Tags.HomeVC.homeTableViewTag:
            let vm = TopicDetailViewControllerViewModel(topic: topics[indexPath.section])
            let vc = TopicDetailViewController(viewModel: vm)
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: false)
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
    func loadMoreButtonClicked(_ sender: UIButton) {
        sender.setTitle("", for: .normal)
        sender.viewWithTag(5)?.removeFromSuperview()
        // activity indicator
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.tag = 5
        indicatorView.frame = sender.bounds
        sender.addSubview(indicatorView)
        indicatorView.startAnimating()
        // Do load more function
        fetchTopics(from: topics.count)
    }
}

// Shuffle helper for array
extension MutableCollection {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: numericCast(arc4random_uniform(numericCast(diff))))
            swapAt(i, j)
        }
    }
}
