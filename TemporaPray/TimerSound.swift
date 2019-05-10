//
//  TimerSound.swift
//  Tempora
//
//  Created by Matthew Poulos on 4/24/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

//import Foundation
import AVFoundation
import UIKit

//protocol

class TimerSound  {
    
    var name : String
    var fileURL: URL
    var filetype: String
    var attribution: String
    private var player: AVAudioPlayer?
    
    
    init(name: String, fileURL: URL, filetype: String, attribution: String) {
        self.name = name
        self.fileURL = fileURL
        self.filetype = filetype
        self.attribution = attribution
        do {
            self.player = try AVAudioPlayer(contentsOf: fileURL, fileTypeHint: filetype)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
//    private var audioSession: AVAudioSession
    
    func play() {
        do {
            
            //player = try AVAudioPlayer(data: asset!.data, fileTypeHint: AVFileType.mp3.rawValue)
            
//            let player = AVAudioPlayerNode()
//            let f = try! AVAudioFile(forReading: url)
//            let mixer = self.engine.
            player?.stop()
            player?.prepareToPlay()
            player!.play()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func play(delay: TimeInterval) {
        do {
            
            //player = try AVAudioPlayer(data: asset!.data, fileTypeHint: AVFileType.mp3.rawValue)
            
            player?.stop()
            player?.prepareToPlay()
            player!.play(atTime: player!.deviceCurrentTime + delay)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func currentTime() -> TimeInterval {
        player?.prepareToPlay()
        return player!.currentTime
    }
    
    func duration() -> TimeInterval {
        player?.prepareToPlay()
        return player!.duration
    }
}

class TimerSoundLibrary {
    
    
    var bundle: Bundle
    var timerSoundsDictionary: [String:TimerSound]
    static private var timerSoundLibrary: TimerSoundLibrary?
    
    private init(soundBundle: Bundle, manifestName: String, withExtension: String) {
        self.bundle = soundBundle
        timerSoundsDictionary = Dictionary() as [String:TimerSound]
        loadSoundBundle(fromBundle: soundBundle, manifestName: manifestName, ext: withExtension)
    }
    
    subscript(key: String) -> TimerSound? {
        get {
            return timerSoundsDictionary[key]
        }
        
        set (newValue) {
            timerSoundsDictionary[key] = newValue
        }
    }
    
    
    
    
    private func loadSoundBundle(fromBundle: Bundle, manifestName: String, ext: String) {
        do {
            let manifestData = try Data(contentsOf: fromBundle.url(forResource: manifestName, withExtension: ext)!, options: .mappedIfSafe)
            let json = try? JSONSerialization.jsonObject(with: manifestData, options: [])
            if let dictionary = json as? [String: Any] {
                for (timerSoundName, timerSoundParams) in dictionary {
                    if let paramsDictionary = timerSoundParams as? [String: String] {
                        let filename = paramsDictionary["filename"]
                        let filetype = paramsDictionary["filetype"]
                        let fileURL = fromBundle.url(forResource: filename, withExtension: filetype)!
                        let attribution = paramsDictionary["attribution"]
                        timerSoundsDictionary[timerSoundName] = TimerSound(name: timerSoundName, fileURL: fileURL, filetype: filetype!, attribution: attribution!)
                    }
                }
            }
        } catch {
            print("error occurred")
        }
    }
    
    static func initialize(soundBundle: Bundle, manifestName: String, withExtension: String) {
        if timerSoundLibrary == nil {
            timerSoundLibrary = TimerSoundLibrary(soundBundle: soundBundle, manifestName: manifestName, withExtension: withExtension)
        }
    }
    
    static func getInstance() -> TimerSoundLibrary? {
        return timerSoundLibrary
    }
    
}
