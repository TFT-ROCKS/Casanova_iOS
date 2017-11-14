//
//  AnswerNoteTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/13/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

class AnswerNoteTableViewCell: UITableViewCell, AVAudioPlayerDelegate {

    var noteTitleLabel: UILabel!
    var noteAudioButton: UIButton!
    
    var answer: Answer! {
        didSet {
            updateUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        noteTitleLabel = UILabel(frame: .zero)
        noteAudioButton = UIButton(frame: .zero)
        
        contentView.addSubview(noteTitleLabel)
        contentView.addSubview(noteAudioButton)
        
        noteTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        noteAudioButton.translatesAutoresizingMaskIntoConstraints = false

        noteAudioButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        noteAudioButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        noteAudioButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        noteAudioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        noteAudioButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        noteTitleLabel?.widthAnchor.constraint(equalToConstant: 100).isActive = true
        noteTitleLabel?.trailingAnchor.constraint(equalTo: noteAudioButton.leadingAnchor, constant: -8).isActive = true
        noteTitleLabel?.centerYAnchor.constraint(equalTo: noteAudioButton.centerYAnchor).isActive = true
        
        // config
        noteTitleLabel.text = "听讲解："
        noteTitleLabel?.font = UIFont.pfl(size: 17)
        noteTitleLabel?.textAlignment = .right
        noteAudioButton.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
        
        contentView.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateUI() {
        
    }
}

