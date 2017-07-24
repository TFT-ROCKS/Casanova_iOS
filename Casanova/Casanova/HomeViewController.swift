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
    
    var topics: [Topic] = [] {
        didSet {
            homeTableView.reloadData()
        }
    }
    
    // const
    let cellVerticalSpace: CGFloat = 15
    let cellHorizontalSpace: CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view setup
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.allowsSelection = false
        homeTableView.backgroundColor = UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1)
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 399
        let homeTableViewCell = UINib(nibName: "HomeTableViewCell", bundle: nil)
        homeTableView.register(homeTableViewCell, forCellReuseIdentifier: "HomeTableViewCell")
        let loadMoreTableViewCell = UINib(nibName: "LoadMoreTableViewCell", bundle: nil)
        homeTableView.register(loadMoreTableViewCell, forCellReuseIdentifier: "LoadMoreTableViewCell")
        
        // Navigation bar setup
        navigationController?.navigationBar.tintColor = UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1)
        navigationController?.navigationBar.setBottomBorderColor(color: UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1), height: 1)
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - TableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return topics.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Hide "Load More" Button if there is no topics present
        if topics.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell {
                cell.topic = topics[indexPath.row]
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTableViewCell", for: indexPath) as? LoadMoreTableViewCell {
                cell.delegate = self
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HomeTableViewCell {
            
            // Visualize the margin surrounding the table view cell
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            
            // remove small whiteRoundedView before adding new one
            for view in cell.contentView.subviews {
                if view.tag == 100 {
                    view.removeFromSuperview()
                }
            }
            
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: cellHorizontalSpace, y: cellVerticalSpace / 2, width: self.view.bounds.width - cellHorizontalSpace * 2, height: cell.bounds.height - cellVerticalSpace / 2))
            whiteRoundedView.tag = 100
            whiteRoundedView.layer.backgroundColor = UIColor.white.cgColor
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.cornerRadius = 5
            whiteRoundedView.layer.shadowOffset = CGSize(width: 0, height: 1)
            whiteRoundedView.layer.shadowOpacity = 0.2
            
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubview(toBack: whiteRoundedView)
            
        } else if let cell = cell as? LoadMoreTableViewCell {
            
            // Visualize the margin surrounding the table view cell
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            
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
