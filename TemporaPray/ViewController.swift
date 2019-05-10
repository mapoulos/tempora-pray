//
//  ViewController.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 4/30/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import UIKit
import AVFoundation
import os
class ViewController: UIViewController {
    @IBOutlet var timerView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    let authorURL = "https://localhost:8080/authors"
    var meditationTimer: PausableTimer = PausableTimer()
    var authorCatalog: [Author] = Array()
    
    var currentAuthor: Author?
    var currentWork: Work?
    var currentSection: Section?
    var soundLibrary: TimerSoundLibrary {
        let soundBundle = Bundle(path: Bundle.main.path(forResource: "Sounds", ofType: "bundle")!)
        TimerSoundLibrary.initialize(soundBundle: soundBundle!, manifestName: "manifest", withExtension: "json")
        os_log("finished loading the sound library")
        return TimerSoundLibrary.getInstance()!
    }
    
    private var authorList: [Author] = Array()
    private var loadingComplete = false
    
    private func loadAuthorCatalog(urlString: String) {
        
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(WebResponse.self, from: data)
                self.authorList = response.getAuthors()!
                //by default select first author, first work, first section
                self.currentAuthor = self.authorList.first
                self.currentWork = self.currentAuthor?.works.first
                self.currentSection = self.currentWork?.sections.first
                let sectionURL = self.currentWork!.sections.first!.audioURL
                let fileCache = FileCache.shared()
                
                fileCache.downloadFileFromURLAsync(urlString: self.currentSection!.audioURL, callback:
                    { (success:Bool) in
                        if success {
                            self.soundLibrary[sectionURL] = TimerSound(name: sectionURL, fileURL: fileCache[sectionURL]!, filetype: "mp3", attribution: "")
                            self.initiateSoundEngine()
                            self.loadingComplete = true
                        }})
                
                os_log("Finished loading the authors' list from the web." )
            } catch {
                print(error)
            }
        
            
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        loadAuthorCatalog(urlString: authorURL)
        updateUILabel()
        
        
        super.viewDidLoad()
        
        
    }
    
    var engine = AVAudioEngine()
    var bellPlayer = AVAudioPlayerNode()
    var bellFile: AVAudioFile?
    var audioPlayer = AVAudioPlayerNode()
    var audioFile: AVAudioFile?
    var bellPlayerEnd = AVAudioPlayerNode()
    
    func initiateSoundEngine() {
        let url1 = soundLibrary["Ship Bell"]!.fileURL
        bellFile = try! AVAudioFile(forReading: url1)
        
        
        let url2 = soundLibrary[currentSection!.audioURL]!.fileURL
        audioFile = try! AVAudioFile(forReading: url2)
        
        engine.attach(bellPlayer)
        engine.attach(bellPlayerEnd)
        engine.attach(audioPlayer)
        engine.connect(bellPlayer, to: engine.mainMixerNode, format: bellPlayer.outputFormat(forBus: 0))
        engine.connect(bellPlayerEnd, to: engine.mainMixerNode, format: bellPlayer.outputFormat(forBus: 0))
        engine.connect(audioPlayer, to: engine.mainMixerNode, format: audioPlayer.outputFormat(forBus: 0))
        
        engine.prepare()
        try! self.engine.start()
        
    }
    
    func delay(_ amount: Double, execute: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + amount) {
            execute()
        }
        
    }
    
    func playSoundFromMixer() {
        
        let outputFormat = bellPlayer.outputFormat(forBus: 0)
        let startSampleTime = bellPlayer.lastRenderTime!.sampleTime
        
        let audioStartTime = AVAudioTime.init(sampleTime: startSampleTime , atRate: outputFormat.sampleRate)
        let delayTime = Double(audioFile!.length) / Double(audioFile!.fileFormat.sampleRate) + 1.0
        let bellEndDelayTime = AVAudioTime.init(sampleTime: audioPlayer.lastRenderTime!.sampleTime + Int64((delayTime * outputFormat.sampleRate)), atRate: outputFormat.sampleRate)
        
        
        bellPlayer.scheduleFile(bellFile!, at: nil, completionHandler: {})
        audioPlayer.scheduleFile(audioFile!, at: audioStartTime, completionHandler: {})
        bellPlayerEnd.scheduleFile(bellFile!, at: bellEndDelayTime, completionHandler: {self.delay(3.0) {self.engine.stop()}})
        
        bellPlayer.play()
        bellPlayerEnd.play()
        audioPlayer.play()
        
    }
    
    func updateUILabel() {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        //                formatter.uni
        let timeRemaining = self.meditationTimer.duration - self.meditationTimer.elapsedTime
        self.timerLabel.text = formatter.string(from: timeRemaining)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton?) {
        
        func showPlayButton() {
            //change the playButton icon
            let playIcon = UIImage(named: "Play_icon")
            sender!.setImage(playIcon, for: [])
        }
        
        func showPauseButton() {
            let pauseIcon = UIImage(named: "Pause_icon")
            sender!.setImage(pauseIcon, for: [])
        }
        
        if(meditationTimer.started() == false) {
            let defaults = UserDefaults()
            let duration = defaults.double(forKey: Preferences.SessionLength.rawValue)
            meditationTimer.duration = duration
            meditationTimer.onEnd = {
               showPlayButton()
                self.meditationTimer.elapsedTime = 0
                try! self.engine.start()
                self.playSoundFromMixer()
            }
            
            
            
            meditationTimer.update = {
                self.updateUILabel()
            }
            
            //play the dong
            
            
            
            if(loadingComplete) {
                showPauseButton()
                DispatchQueue.global(qos: .userInitiated).async {
//                    let bellSound = self.soundLibrary["Ship Bell"]!
//
//                    bellSound.play()
//
//                    let sectionAudio = self.soundLibrary[self.currentSection!.audioURL]!
//                    sectionAudio.play(delay: bellSound.duration())

                    self.playSoundFromMixer()
                    
                }
                self.meditationTimer.start()
            }
            
            
            
            
            
        } else {
            if(meditationTimer.isRunning == true) {
                showPlayButton()
                meditationTimer.pause()
            } else {
                showPauseButton()
    
                meditationTimer.resume()
            }
            
        }
    }


}

