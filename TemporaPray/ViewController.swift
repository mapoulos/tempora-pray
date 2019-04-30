//
//  ViewController.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 4/30/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var timerView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var meditationTimer: PausableTimer = PausableTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func playButtonPressed(_ sender: Any?) {
        if(meditationTimer.started() == false) {
            let defaults = UserDefaults()
            let duration = defaults.double(forKey: Preferences.SessionLength.rawValue)
            meditationTimer.duration = duration
            meditationTimer.onEnd = {
                //change the playButton icon
            }
            
            
            meditationTimer.update = {
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                formatter.allowedUnits = [.hour, .minute, .second]
                let timeRemaining = self.meditationTimer.duration - self.meditationTimer.elapsedTime
                self.timerLabel.text = formatter.string(from: timeRemaining)
            }
            meditationTimer.start()
        } else {
            if(meditationTimer.isRunning == true) {
                meditationTimer.pause()
            } else {
                meditationTimer.resume()
            }
            //change button 
        }
    }


}

