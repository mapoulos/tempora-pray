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
    let authorURL = "https://localhost:8080/authors"
    let defaults = UserDefaults()
    lazy var meditationTimer = PausableTimer(duration: 0, update: {}, onPause: {}, onResume: {}, onEnd: {})
    
    var authorCatalog: [Author] = Array()
    
    var currentAuthor: Author?
    var currentWork: Work?
    var currentSection: Section?
    var soundLibrary: TimerSoundLibrary {
        if(TimerSoundLibrary.getInstance() == nil) {
            let soundBundle = Bundle(path: Bundle.main.path(forResource: "Sounds", ofType: "bundle")!)
            TimerSoundLibrary.initialize(soundBundle: soundBundle!, manifestName: "manifest", withExtension: "json")
            os_log("finished loading the sound library")
        }
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
//                            self.initiateSoundEngine()
                            self.loadingComplete = true
                        }})
                
                os_log("Finished loading the authors' list from the web." )
            } catch {
                print(error)
            }
        
            
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RootViewToSelectWork" {
            let authTableViewController = segue.destination as! AuthorTableViewController
            authTableViewController.authors = self.authorList
            self.navigationController?.isNavigationBarHidden = false;
        }
    }
    
    @IBAction func sectionSelected(_seg: UIStoryboardSegue) {
        
    }
    
    
    
    @objc func onDefaultsChange(_ notification:Notification) {
        let defaults = UserDefaults()
        let dur = defaults.double(forKey: Preferences.SessionLength.rawValue)
        meditationTimer.duration = dur
        self.updateUILabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        if currentAuthor != nil {
            loadingComplete = true
            FileCache.shared().downloadFileFromURLAsync(urlString: currentSection!.audioURL, callback: { (success:Bool) in
                    if success {
                        let fileCache = FileCache.shared()
                        let sectionURL = self.currentSection!.audioURL
                        self.soundLibrary[sectionURL] = TimerSound(name: sectionURL, fileURL: fileCache[sectionURL]!, filetype: "mp3", attribution: "")
                        
                    }

            })
            self.meditationButton.titleLabel!.text = "\(currentAuthor!.name),  \(currentSection!.number)"
//            self.meditationButton.widthAnchor
        }
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        loadAuthorCatalog(urlString: authorURL)
        
        self.updateUILabel()
        NotificationCenter.default.addObserver(self, selector: #selector(onDefaultsChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
        
        super.viewDidLoad()
        meditationTimer.duration = UserDefaults().double(forKey: Preferences.SessionLength.rawValue)
        self.updateUILabel()
        let upswipe = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeHandler))
        upswipe.direction = .up
        
        let downswipe = UISwipeGestureRecognizer.init(target: self, action:#selector(swipeHandler))
        downswipe.direction = .down
        timerView.addGestureRecognizer(upswipe)
        timerView.addGestureRecognizer(downswipe)
        
        
    }
    
    @objc func swipeHandler(_ obj : UISwipeGestureRecognizer) {
        
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
        
        print("Swiping \(obj.direction)")
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
    
    func updateUILabel() {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        //                formatter.uni
        let timeRemaining = self.meditationTimer.duration - self.meditationTimer.elapsedTime    
        self.timerLabel.text = formatter.string(from: timeRemaining)
        //self.meditationButton.titleLabel!.text = "Evag"
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
            meditationTimer.onPause = {
                self.engine.pause()
            }
            
            meditationTimer.onResume = {
                try! self.engine.start()
            }
            
            meditationTimer.onEnd = {
               showPlayButton()
                self.updateUILabel()
                self.meditationTimer.elapsedTime = 0
                self.engine.stop()

            }
            
            meditationTimer.update = {
                self.updateUILabel()
            }
            
            
            if(loadingComplete) {
                showPauseButton()
                updateUILabel()
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

