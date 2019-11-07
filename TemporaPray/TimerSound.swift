//
//  TemporaSound.swift
//  Tempora
//
//  Created by Matthew Poulos on 4/24/19.
//  Copyright © 2019 Equulus. All rights reserved.
//


import AVFoundation
import UIKit
import os

/*
    This class is used to load audio files
    sounds
 */
class TemporaSound  {
    
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
    }
}

public class TimerSoundLibrary {
    
    
    var bundle: Bundle
    var timerSoundsDictionary: [String:TemporaSound]
    static private var timerSoundLibrary: TimerSoundLibrary?
    
    private init(soundBundle: Bundle, manifestName: String, withExtension: String) {
        self.bundle = soundBundle
        timerSoundsDictionary = Dictionary() as [String:TemporaSound]
        loadSoundBundle(fromBundle: soundBundle, manifestName: manifestName, ext: withExtension)
    }
    
    subscript(key: String) -> TemporaSound? {
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
                        timerSoundsDictionary[timerSoundName] = TemporaSound(name: timerSoundName, fileURL: fileURL, filetype: filetype!, attribution: attribution!)
                    }
                }
            }
        } catch {
            os_log("Error occurred while loading sound bundle")
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
