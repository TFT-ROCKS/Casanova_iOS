//
//  ViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBAction func postCommentBtnDidClicked(_ sender: UIButton) {
        let newComment = Comment(timestamp: player.currentTime, text: commentTextField.text!)
        comments.append(newComment)
        commentTextField.text = ""
    }
    @IBAction func startButtonClicked(_ sender: UIButton) {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        player.play()
    }
    @IBAction func pauseButtonClicked(_ sender: UIButton) {
        player.pause()
    }
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        player.stop()
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player.currentTime = TimeInterval(slider.value)
        timeLabel.text = stringFromTimeInterval(player.currentTime)
    }
    
    func updateTime(_ timer: Timer) {
        slider.value = Float(player.currentTime)
        timeLabel.text = stringFromTimeInterval(player.currentTime)
    }
    
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        
        let ti = Int(interval)
        
        let ms = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
    
    var player: AVAudioPlayer!
    
    var comments: [Comment] = [] {
        didSet {
            commentsTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //UserManager.shared.signUp(username: "xguo-test-03", email: "xyg-test-02@gmail.com", password: "123456")
        //UserManager.shared.signIn(email: "xyg-test-02@gmail.com", password: "123456")
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        let path = Bundle.main.path(forResource: "test.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            // couldn't load file :(
        }
        player.prepareToPlay()
        slider.maximumValue = Float(player.duration)
        slider.value = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell {
            let comment = comments[indexPath.row]
            
            cell.comment = comment
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let comment = comments[indexPath.row]
        player.currentTime = comment.timestamp
        slider.value = Float(player.currentTime)
        timeLabel.text = stringFromTimeInterval(player.currentTime)
        tableView.reloadData()
    }
}

