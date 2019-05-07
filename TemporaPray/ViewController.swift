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
    var authorCatalog: [Author] = Array()
    
//    func test() {
//    do {
//    let manifestData = try Data(contentsOf: fromBundle.url(forResource: manifestName, withExtension: ext)!, options: .mappedIfSafe)
//    let json = try? JSONSerialization.jsonObject(with: manifestData, options: [])
//    if let dictionary = json as? [String: Any] {
//    for (timerSoundName, timerSoundParams) in dictionary {
//    if let paramsDictionary = timerSoundParams as? [String: String] {
//    let filename = paramsDictionary["filename"]
//    let filetype = paramsDictionary["filetype"]
//    let attribution = paramsDictionary["attribution"]
//    timerSoundsDictionary[timerSoundName] = TimerSound(name: timerSoundName, filename: filename!, filetype: filetype!, attribution: attribution!)
//    }
//    }
//    }
//    } catch {
//    print("error occurred")
//    }
//    }
    
    private var authorList: [Author] = Array()
    
    private func loadAuthorCatalog(urlString: String) {
        
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(WebResponse.self, from: data)
                self.authorList = response.getAuthors()!
            } catch {
                print(error)
            }
        
            
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadAuthorCatalog(urlString: "https://localhost:8080/authors")
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

