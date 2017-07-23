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

        // Do any additional setup after loading the view.
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.allowsSelection = false
        homeTableView.backgroundColor = UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1)
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.estimatedRowHeight = 399
        let homeTableViewCell = UINib(nibName: "HomeTableViewCell", bundle: nil)
        homeTableView.register(homeTableViewCell, forCellReuseIdentifier: "HomeTableViewCell")
        
        // Fetch topics
        TopicManager.shared.fetchTopics(withCompletion: { (error, topics) in
            if error == nil {
                // success
                self.topics = topics!
            } else {
                // error found
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell {
            cell.topic = topics[indexPath.row]
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HomeTableViewCell {
            
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
            
        }
    }
}
