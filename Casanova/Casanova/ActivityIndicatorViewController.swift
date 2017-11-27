//
//  ActivityIndicatorViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class ActivityIndicatorViewController: UIViewController {

    var activityIndicatorView: UIActivityIndicatorView!
    var activityTitleLabel: UILabel!
    var activityTitle: String!
    
    init(activityTitle: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.activityTitle = activityTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        layoutActivityIndicatorView()
        layoutActivityTitleLabel()
        configActivityTitleLabel()
        activityIndicatorView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func layoutActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        // constraints
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func layoutActivityTitleLabel() {
        activityTitleLabel = UILabel(frame: .zero)
        view.addSubview(activityTitleLabel)
        activityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // constraints
        activityTitleLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        activityTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityTitleLabel.topAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 10).isActive = true
    }
    
    func configActivityTitleLabel() {
        activityTitleLabel.numberOfLines = 0
        activityTitleLabel.font = UIFont.pfr(size: 18)
        activityTitleLabel.textColor = UIColor.white
        activityTitleLabel.textAlignment = .center
        activityTitleLabel.text = activityTitle
    }
}
