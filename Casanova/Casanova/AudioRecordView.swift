//
//  AudioRecordView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class AudioRecordView: UIView {
    // sub views
    var recordCircleView: AnimatedCircleView!
    var recordImageView: UIImageView!
    var uploadCircleView: AnimatedCircleView!
    var uploadImageView: UIImageView!
    var label: UILabel!
    
    // vars
    var isRecording: Bool = true
    var count = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit() {
        // config
        label.font = UIFont.pfr(size: 18)
        label.textColor = UIColor.tftCoolGrey
        label.textAlignment = .center
        
        // hide upload view
        uploadCircleView.isHidden = true
        uploadImageView.isHidden = true
        
        // image
        recordImageView.image = #imageLiteral(resourceName: "speaking_bar_h")
        recordImageView.contentMode = .scaleAspectFit
        uploadImageView.image = #imageLiteral(resourceName: "check")
        uploadImageView.contentMode = .scaleAspectFit
    }

    override func layoutSubviews() {
        // subviews contraints
        recordCircleView = AnimatedCircleView(frame: .zero, strokeColor: UIColor(red: 15/255.0, green: 181/255.0, blue: 228/255.0, alpha: 1).cgColor, fillColor: UIColor(red: 15/255.0, green: 181/255.0, blue: 228/255.0, alpha: 0.2).cgColor)
        recordImageView = UIImageView(frame: .zero)
        uploadCircleView = AnimatedCircleView(frame: .zero, strokeColor: UIColor(red: 85/255.0, green: 222/255.0, blue: 166/255.0, alpha: 1).cgColor, fillColor: UIColor(red: 85/255.0, green: 222/255.0, blue: 166/255.0, alpha: 0.2).cgColor)
        uploadImageView = UIImageView(frame: .zero)
        label = UILabel(frame: .zero)
        
        addSubview(uploadCircleView)
        addSubview(uploadImageView)
        addSubview(recordCircleView)
        addSubview(recordImageView)
        addSubview(label)
        
        recordCircleView.translatesAutoresizingMaskIntoConstraints = false
        recordImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadCircleView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        uploadCircleView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        uploadCircleView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        uploadCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        uploadCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20).isActive = true
        
        uploadImageView.leadingAnchor.constraint(equalTo: uploadCircleView.leadingAnchor, constant: 19).isActive = true
        uploadImageView.trailingAnchor.constraint(equalTo: uploadCircleView.trailingAnchor, constant: -19).isActive = true
        uploadImageView.topAnchor.constraint(equalTo: uploadCircleView.topAnchor, constant: 19).isActive = true
        uploadImageView.bottomAnchor.constraint(equalTo: uploadCircleView.bottomAnchor, constant: -19).isActive = true
        
        recordCircleView.leadingAnchor.constraint(equalTo: uploadCircleView.leadingAnchor, constant: 0).isActive = true
        recordCircleView.trailingAnchor.constraint(equalTo: uploadCircleView.trailingAnchor, constant: 0).isActive = true
        recordCircleView.topAnchor.constraint(equalTo: uploadCircleView.topAnchor, constant: 0).isActive = true
        recordCircleView.bottomAnchor.constraint(equalTo: uploadCircleView.bottomAnchor, constant: 0).isActive = true
        
        recordImageView.leadingAnchor.constraint(equalTo: recordCircleView.leadingAnchor, constant: 19).isActive = true
        recordImageView.trailingAnchor.constraint(equalTo: recordCircleView.trailingAnchor, constant: -19).isActive = true
        recordImageView.topAnchor.constraint(equalTo: recordCircleView.topAnchor, constant: 19).isActive = true
        recordImageView.bottomAnchor.constraint(equalTo: recordCircleView.bottomAnchor, constant: -19).isActive = true
        
        label.widthAnchor.constraint(equalToConstant: 50).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: uploadCircleView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: uploadCircleView.bottomAnchor, constant: 15).isActive = true
        
        commonInit()
    }
    
    func animate() {
//        recordCircleView.animateForRecording(duration: 60, toValue: 1)
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                DispatchQueue.main.async {
                    self.count += 1
                    self.recordCircleView.animateForUploading(with: Float(self.count) / 60.0)
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
}
