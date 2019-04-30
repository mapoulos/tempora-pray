//
//  WorkSessionTimer.swift
//  Tempora
//
//  Created by Matthew Poulos on 4/18/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Foundation




class PausableTimer {
    
    // duration in seconds
    var duration: TimeInterval
    // function to call on update
    var update: () -> ()
    //block to call on pause
    var onPause: () -> ()
    //block to call on end
    var onEnd: () -> ()
    //elapsed time
    var elapsedTime: TimeInterval
    //timer
    var timer: Timer?
    //isRunning
    var isRunning: Bool
    //start time
    var lastTimerCall: Date
    
    
    let updateInterval = 1
    
    init() {
        duration = 3600
        update = {}
        onPause = {}
        onEnd = {}
        elapsedTime = 0
        timer = nil
        isRunning = false
        lastTimerCall = Date()
    }
    
    init(duration: TimeInterval, update: @escaping () -> (), onPause: @escaping () -> (), onEnd: @escaping () -> ()) {
        self.duration = duration
        self.update = update
        self.onPause = onPause
        self.onEnd = onEnd
        self.elapsedTime = 0
        timer = nil
        self.isRunning = false
        lastTimerCall = Date()
    }
    
    //if the timer has been started
    func started() -> Bool {
        if(isRunning == false && timer == nil) {
            return false
        } else {
            return true
        }
    }
    
    func start() {
        //update
        if(isRunning == false && timer == nil) {
            isRunning = true
            lastTimerCall = Date()
            timer = Timer(timeInterval: 1.0, target: self, selector: #selector(swiftTimerFired), userInfo: nil, repeats: true)
            timer?.tolerance = 0.2
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    func pause() {
        if(isRunning == true) {
            isRunning = false
            self.onPause()
        }
    }
    
    func resume() {
        if(isRunning == false) {
            isRunning = true
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        elapsedTime = 0
    }
    
    @objc private  func swiftTimerFired() {
        let currentTime = Date()
        if(isRunning) {
            elapsedTime += currentTime.timeIntervalSince(lastTimerCall)
            
            
            if(elapsedTime >= self.duration) {
                //end
                self.stop()
                self.onEnd()
            } else {
                self.update()
            }
        }
        lastTimerCall = currentTime
        
    }
    
    
}

