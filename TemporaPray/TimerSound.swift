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

class TimerSound {
    // https://freesound.org/people/juskiddink/sounds/122647/
    
    var name : String
    var filename: String
    var filetype: String
    var attribution: String
    
    
    
    init(name: String, filename: String, filetype: String, attribution: String) {
        self.name = name
        self.filename = filename
        self.filetype = filetype
        self.attribution = attribution
    }
    
    private var player: AVAudioPlayer?
    
    func play() {
        guard let url = TimerSoundLibrary.getInstance()!.bundle.url(forResource: filename, withExtension: filetype) else { print("url not found") ; return }
        
        do {
            
            //player = try AVAudioPlayer(data: asset!.data, fileTypeHint: AVFileType.mp3.rawValue)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: filetype)
        
            player!.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
//    static func playSound(bundle: Bundle, timerSound: TimerSound) {
//        
//        guard let url = bundle.url(forResource: timerSound.filename, withExtension: timerSound.filetype) else { print("url not found") ; return }
//        
//        do {
//            
//            //player = try AVAudioPlayer(data: asset!.data, fileTypeHint: AVFileType.mp3.rawValue)
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: timerSound.filetype)
//            player!.play()
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//    }
    
    
    
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
    
    
    
    private func loadSoundBundle(fromBundle: Bundle, manifestName: String, ext: String) {
        do {
            let manifestData = try Data(contentsOf: fromBundle.url(forResource: manifestName, withExtension: ext)!, options: .mappedIfSafe)
            let json = try? JSONSerialization.jsonObject(with: manifestData, options: [])
            if let dictionary = json as? [String: Any] {
                for (timerSoundName, timerSoundParams) in dictionary {
                    if let paramsDictionary = timerSoundParams as? [String: String] {
                        let filename = paramsDictionary["filename"]
                        let filetype = paramsDictionary["filetype"]
                        let attribution = paramsDictionary["attribution"]
                        timerSoundsDictionary[timerSoundName] = TimerSound(name: timerSoundName, filename: filename!, filetype: filetype!, attribution: attribution!)
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
