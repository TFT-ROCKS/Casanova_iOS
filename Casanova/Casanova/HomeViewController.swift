//
//  HomeViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    // Filter view data
    let tpoArray = ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5", "Task 6"]
    let catArray = ["Education", "Culture", "Family", "Job", "Activity", "Technology", "Places", "Environment", "Others"]
    let levelArray = ["Beginner", "Easy", "Medium", "Hard", "Ridiculous"]
    
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
        
    }
    
    func fetchTopics(from: Int) {
        // Fetch topics
        TopicManager.shared.fetchTopics(from: from, withCompletion: { (error, topics) in
            if error == nil {
                // success
                self.topics.append(contentsOf: topics!)
            } else {
                // error found
            }
        })
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
        }
    }
    
    func searchButtonClicked(_ sender: UIBarButtonItem) {
        
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
            return cell
        case Tags.HomeVC.levelTableViewTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell, for: indexPath) as! FilterTableViewCell
            cell.title.text = levelArray[indexPath.row]
            return cell
        case Tags.HomeVC.catTableViewTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.HomeVC.FilterView.filterTableViewCell, for: indexPath) as! FilterTableViewCell
            cell.title.text = catArray[indexPath.row]
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
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = TopicDetailViewController(withTopic: topics[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
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
