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
    //@IBOutlet var timerView: UIView!
    
    @IBOutlet var timerView: UIView!
    @IBOutlet weak var meditationButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    let defaults = UserDefaults()
    lazy var meditationTimer = PausableTimer(duration: 0, update: {}, onPause: {}, onResume: {}, onEnd: {})
    
    var authorCatalog: [Author] = []
    
    var currentAuthor: Author?
    var currentWork: Work?
    var currentSection: Section?
    var sectionIndex = 0
    
    var soundLibrary: TimerSoundLibrary {
        if(TimerSoundLibrary.getInstance() == nil) {
            let soundBundle = Bundle(path: Bundle.main.path(forResource: "Sounds", ofType: "bundle")!)
            TimerSoundLibrary.initialize(soundBundle: soundBundle!, manifestName: "manifest", withExtension: "json")
            os_log("finished loading the sound library")
        }
        return TimerSoundLibrary.getInstance()!
    }
    
//    private var authorList: [Author] = Array()
    private var loadingComplete = false
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RootViewToSelectWork" {
            let authTableViewController = segue.destination as! AuthorTableViewController
            authTableViewController.authors = self.authorCatalog
            self.navigationController?.isNavigationBarHidden = false;
        }
    }
    
    @IBAction func sectionSelected(_seg: UIStoryboardSegue) {
        
    }
    
    
    
    @objc func onDefaultsChange(_ notification:Notification) {
        let defaults = UserDefaults()
        let dur = defaults.double(forKey: Preferences.SessionLength.rawValue)
        meditationTimer.duration = dur
        self.updateDurationLabel()
    }
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.settingsButton.isHidden = true
        self.stopButton.isHidden = true
        
    
        // setup the present author, async download the current meditation file
        if currentAuthor == nil {
            authorCatalog = Catalog.shared().authors
            currentAuthor = authorCatalog.first ?? Author(name: "", works: [], info: "")
            currentWork = currentAuthor?.works.first ?? Work()
            currentSection = currentWork?.sections.first ?? Section(number: "", text: "Select Work", audioURL: "")
            let sectionURL = self.currentWork?.sections.first?.audioURL ?? ""
            let fileCache = FileCache.shared()
            
            if currentSection?.audioURL != "" {
                fileCache.downloadFileFromURLAsync(urlString: self.currentSection!.audioURL, callback:
                    { (success:Bool) in
                        if success {
                            self.soundLibrary[sectionURL] = TimerSound(name: sectionURL, fileURL: fileCache[sectionURL]!, filetype: "mp3", attribution: "")
                            self.loadingComplete = true
                        }})
            }
            self.updateMeditationButton()
        } else {
            loadingComplete = true
            FileCache.shared().downloadFileFromURLAsync(urlString: currentSection!.audioURL, callback: { (success:Bool) in
                    if success {
                        let fileCache = FileCache.shared()
                        let sectionURL = self.currentSection!.audioURL
                        self.soundLibrary[sectionURL] = TimerSound(name: sectionURL, fileURL: fileCache[sectionURL]!, filetype: "mp3", attribution: "")
                        
                    }

            })
            self.updateMeditationButton()
            
        }
    }
    
    func updateMeditationButton() {
        self.meditationButton.setTitle("\(currentAuthor!.name), \(currentWork!.name) \(currentSection!.number)", for: UIControl.State.disabled)
        self.meditationButton.setTitle("\(currentAuthor!.name), \(currentWork!.name) \(currentSection!.number)", for: UIControl.State.normal)
    }
    
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        
        
        //get notified when prefs change
        NotificationCenter.default.addObserver(self, selector: #selector(onDefaultsChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
        
        //setup the meditation timer for the saved value, and update the duration label
        meditationTimer.duration = UserDefaults().double(forKey: Preferences.SessionLength.rawValue)
        self.updateDurationLabel()
        
        //add the swipes recognizers
        func addGesturesRecognizers() {
            let upswipe = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeHandler))
            upswipe.direction = .up
            
            let downswipe = UISwipeGestureRecognizer.init(target: self, action:#selector(swipeHandler))
            downswipe.direction = .down
            
            let leftSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeHandler))
            leftSwipe.direction = .left
            
            let rightSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeHandler))
            rightSwipe.direction = .right
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapHandler))
            
            timerView.addGestureRecognizer(upswipe)
            timerView.addGestureRecognizer(downswipe)
            timerView.addGestureRecognizer(leftSwipe)
            timerView.addGestureRecognizer(rightSwipe)
            timerView.addGestureRecognizer(tap)
        }
        
        addGesturesRecognizers()
        
        
    }
    @objc func tapHandler(_obj : UITapGestureRecognizer) {
        
        settingsButton.isHidden.toggle()
        stopButton.isHidden.toggle()
    }
    
    func moveSectionIndexRight() {
        if(sectionIndex >= currentWork!.sections.count-1) {
            sectionIndex = 0
        } else {
            sectionIndex += 1
        }
        currentSection = currentWork!.sections[sectionIndex]
        self.updateMeditationButton()
    }
    
    func moveSectionIndexLeft() {
        if(sectionIndex <= 0) {
            sectionIndex = currentWork!.sections.count - 1
        } else {
            sectionIndex -= 1
        }
        currentSection = currentWork!.sections[sectionIndex]
        self.updateMeditationButton()
    }
    
    @objc func swipeHandler(_ obj : UISwipeGestureRecognizer) {
    
        // handle left and right swipes
        if obj.direction == .right {
            moveSectionIndexLeft()
            os_log("moved section index left")
            return
        } else if obj.direction == .left {
            moveSectionIndexRight()
            os_log("moved section index right")
            return
        }
        
        // handle up and down swipes
        if (meditationTimer.isRunning == false && meditationTimer.started() == false) {
            let defaults = UserDefaults()
            let curSessionLength = defaults.double(forKey: Preferences.SessionLength.rawValue)
            
            switch obj.direction {
            case .up:
                defaults.setValue(curSessionLength+300, forKey: Preferences.SessionLength.rawValue)
                defaults.synchronize()
                os_log("increased session length by 5 minutes")
            case .down:
                if(curSessionLength > 300) {
                    defaults.setValue(curSessionLength-300, forKey: Preferences.SessionLength.rawValue)
                
                }
                defaults.synchronize()
                os_log("decreased session length by 5 minutes")
           
            default:
                print("Unexpected swipe")
            }
        }
        
    }
    
    var engine = AVAudioEngine()
    var bellFile: AVAudioFile?
    var meditationFile: AVAudioFile?
    
    var bellBuffer: AVAudioPCMBuffer?
    var meditationBuffer: AVAudioPCMBuffer?

    var bellPlayer = AVAudioPlayerNode()
    var meditationPlayer = AVAudioPlayerNode()

    
    
    func initiateSoundEngine() {
        
        func loadMeditationBuffer() {
            let url2 = soundLibrary[currentSection!.audioURL]!.fileURL
            meditationFile = try! AVAudioFile(forReading: url2)
            meditationBuffer = AVAudioPCMBuffer(pcmFormat: meditationFile!.processingFormat, frameCapacity: UInt32(meditationFile?.length ?? 0))
            try! meditationFile!.read(into: meditationBuffer!)
        }
        
        loadMeditationBuffer()
        
        func loadBellBuffer() {
            let url1 = soundLibrary["Ship Bell"]!.fileURL
            bellFile = try! AVAudioFile(forReading: url1)
            //             let manifestFile =
            
            let format = bellFile!.processingFormat
            let length = bellFile!.length
            bellBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(length))
            try! bellFile!.read(into: bellBuffer!)
        }
        loadBellBuffer()
        
        
        func attachPlayers() {
            engine.attach(bellPlayer)
            engine.attach(meditationPlayer)
        }
        
        attachPlayers()
        
        func connectPlayersToMainMixer() {
            engine.connect(bellPlayer, to: engine.mainMixerNode, format: bellFile!.processingFormat)
            engine.connect(meditationPlayer, to: engine.mainMixerNode, format: meditationFile!.processingFormat)
        }
        
        connectPlayersToMainMixer()
        
        engine.prepare()
        try! self.engine.start()
        
    }
    
    func delay(_ amount: Double, execute: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + amount) {
            execute()
        }
        
    }
    
    func scheduleSounds() {
        let outputFormat = self.bellPlayer.outputFormat(forBus: 0)
        let bellLength = Double(bellFile!.length) / outputFormat.sampleRate
        let meditationLength = Double(meditationFile!.length) / outputFormat.sampleRate
        let sessionLength = meditationTimer.duration
        let gapFollowingMeditation = 1.0
        
        func secToFrame(_ seconds : Double) -> AVAudioTime {
            return AVAudioTime.init(sampleTime: Int64(seconds*outputFormat.sampleRate), atRate: outputFormat.sampleRate)
        }
        
        bellPlayer.scheduleBuffer(bellBuffer!, at: nil) {}
        meditationPlayer.scheduleBuffer(meditationBuffer!, at: secToFrame(bellLength)) {}
        bellPlayer.scheduleBuffer(bellBuffer!, at: secToFrame(bellLength+meditationLength+1)) {}
        
        bellPlayer.scheduleBuffer(bellBuffer!, at: secToFrame(sessionLength-bellLength*2-meditationLength-gapFollowingMeditation)) {}
        meditationPlayer.scheduleBuffer(meditationBuffer!, at: secToFrame(sessionLength-bellLength-meditationLength-gapFollowingMeditation)) {}
        bellPlayer.scheduleBuffer(bellBuffer!, at: secToFrame(sessionLength-bellLength)) {}
        

        bellPlayer.play()
        meditationPlayer.play()
    }
    
    func updateDurationLabel() {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        //                formatter.uni
        let timeRemaining = self.meditationTimer.duration - self.meditationTimer.elapsedTime    
        self.timerLabel.text = formatter.string(from: timeRemaining)
        //self.meditationButton.titleLabel!.text = "Evag"
    }
    
    
    @IBOutlet weak var playButton: UIButton!
    private func showPlayButton() {
        //change the playButton icon
        let playIcon = UIImage(named: "Play_icon")
        playButton.setImage(playIcon, for: [])
    }
    
    private func showPauseButton() {
        let pauseIcon = UIImage(named: "Pause_icon")
        playButton.setImage(pauseIcon, for: [])
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        // if playing, reset time, stop timers, stop sound engine
        if(meditationTimer.started() == true) {
            meditationTimer.stop()
            self.meditationButton.isEnabled = true
            showPlayButton()
            updateDurationLabel()
            engine.stop()
        }
    }
    
    
    
    @IBAction func playButtonPressed(_ sender: UIButton?) {
        
        if(meditationTimer.started() == false) {
            
            let defaults = UserDefaults()
            let duration = defaults.double(forKey: Preferences.SessionLength.rawValue)
            meditationButton.isEnabled = false
            updateMeditationButton()
            
            meditationTimer.duration = duration
            meditationTimer.onPause = {
                self.engine.pause()
            }
            
            meditationTimer.onResume = {
                try! self.engine.start()
            }
            
            meditationTimer.onEnd = {
               self.showPlayButton()
                self.updateDurationLabel()
                self.meditationTimer.elapsedTime = 0
                self.engine.stop()
                self.meditationButton.isEnabled = true
                self.moveSectionIndexRight()

            }
            
            meditationTimer.update = {
                self.updateDurationLabel()
            }
            
            
            if(loadingComplete) {
                showPauseButton()
                updateDurationLabel()
                DispatchQueue.global(qos: .userInitiated).async {
                    self.initiateSoundEngine()
                    self.scheduleSounds()
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

