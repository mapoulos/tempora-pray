//
//  ViewController.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 4/30/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import UIKit
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
        
        
        
        super.viewDidLoad()
        
        
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
            }
            
            
            
            meditationTimer.update = {
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                formatter.allowedUnits = [.hour, .minute, .second]
                let timeRemaining = self.meditationTimer.duration - self.meditationTimer.elapsedTime
                self.timerLabel.text = formatter.string(from: timeRemaining)
            }
            
            //play the dong
            
            showPauseButton()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.soundLibrary["Ship Bell"]!.play()
                
            }
            FileCache.shared().downloadFileFromURLAsync(urlString: currentSection!.audioURL)
            self.meditationTimer.start()
            
            
            
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

