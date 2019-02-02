//
//  AudioPlayManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 1/9/19.
//  Copyright © 2019 Xiaoyu Guo. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayManagerDelegate: class {
    func didStartPlaying(audioPlayer: AVAudioPlayer?, sender: AnyObject?)
    func didFinishPlaying(audioPlayer: AVAudioPlayer?, sender: AnyObject?)
}

class AudioPlayManager: NSObject {
    
    static let shared = AudioPlayManager()
    
    weak var delegate: AudioPlayManagerDelegate?
    weak var sender: AnyObject?
    
    var audioPlayer: AVAudioPlayer?
    var downloadTask: URLSessionDownloadTask?
    var timer: Timer?
    
    // --------------------------------------------------------------------------------------------------------
    // MARK:                                        Public Methods
    // --------------------------------------------------------------------------------------------------------
    
    public func prepareToPlay() {
        stop() // Stop the previous play if any
        delegate?.didFinishPlaying(audioPlayer: audioPlayer, sender: sender)
        
    }
    
    public func play(url: URL, delegate: AudioPlayManagerDelegate?, sender: AnyObject?) {
        self.delegate = delegate
        self.sender = sender
        
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] (URL, response, error) -> Void in
            self?.play(url: URL!)
        })
        downloadTask?.resume()
    }
    
    public func pause() {
        audioPlayer?.pause()
    }
    
    public func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    public var isPlaying: Bool {
        get {
            return audioPlayer?.isPlaying ?? false
        }
    }
    
    public var duration: TimeInterval {
        get {
            return audioPlayer?.duration ?? 0.0
        }
    }
    
    public var url: URL? {
        get {
            return audioPlayer?.url
        }
    }
    
    public var data: Data? {
        get {
            return audioPlayer?.data
        }
    }
    
    public var pan: Float {
        set {
            audioPlayer?.pan = newValue
        }
        get {
            return audioPlayer?.pan ?? 0.0
        }
    }
    
    public var volume: Float {
        set {
            audioPlayer?.volume = newValue
        }
        get {
            return audioPlayer?.volume ?? 0.0
        }
    }
    
    public var enableRate: Bool {
        set {
            audioPlayer?.enableRate = newValue
        }
        get {
            return audioPlayer?.enableRate ?? false
        }
    }
    
    public var rate: Float {
        set {
            audioPlayer?.rate = newValue
        }
        get {
            return audioPlayer?.rate ?? 0.0
        }
    }
    
    public var currentTime: TimeInterval {
        set {
            audioPlayer?.currentTime = newValue
        }
        get {
            return audioPlayer?.currentTime ?? 0.0
        }
    }
    
    // --------------------------------------------------------------------------------------------------------
    // MARK:                                        Private Methods
    // --------------------------------------------------------------------------------------------------------
    
    func play(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            audioPlayer = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
        if let audioPlayer = self.audioPlayer {
            audioPlayer.delegate = self
            audioPlayer.enableRate = true
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
            
            delegate?.didStartPlaying(audioPlayer: audioPlayer, sender: sender)
        }
    }
}

extension AudioPlayManager : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
        delegate?.didFinishPlaying(audioPlayer: player, sender: sender)
    }
}
