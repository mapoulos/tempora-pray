//
//  WorkSession.swift
//  Tempora
//
//  Created by Matthew Poulos on 4/23/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Foundation


class WorkSession {
    
    private var sessionTimer: PausableTimer
    private var timeToBreakTimer: PausableTimer
    private var breakTimer: PausableTimer
    
    
    //var breakDuration: TimeInterval
    
    
    func updateSessionParameters(sessionDuration: TimeInterval, breakDuration: TimeInterval, breakCount: Int) {
        self.sessionTimer.duration = sessionDuration
        
        self.totalBreaks = breakCount
        self.timeToBreakTimer.duration = sessionTimer.duration / Double(totalBreaks + 1 ) - breakDuration / 2.0
        self.breakTimer.duration = breakDuration
    }
    
    
    func getSessionDuration() -> TimeInterval {
        return sessionTimer.duration
    }
    
    func getDurationToBreak() -> TimeInterval {
        return timeToBreakTimer.duration
    }
    
    func getBreakDuration() -> TimeInterval {
        return breakTimer.duration
    }
    
    
    
    func getElapsedTimeSession() -> TimeInterval {
        return sessionTimer.elapsedTime
    }
    
    func getElapsedTimeToBreak() -> TimeInterval {
        return timeToBreakTimer.elapsedTime
    }
    
    func getElapsedTimeInBreak() -> TimeInterval {
        return breakTimer.elapsedTime
    }
    
    var totalBreaks: Int
    var breakCounter: Int
    
    var update: () -> ()
    var onSessionEnd: () -> ()
    var onBreakStart: () -> ()
    var onBreakEnd: () -> ()
    var onStop: () -> ()
    var onPause: () -> ()
    
    
    init() {
        sessionTimer = PausableTimer()
        timeToBreakTimer = PausableTimer()
        breakTimer = PausableTimer()
        totalBreaks = 1
        breakCounter = 0
        update = {}
        onSessionEnd = {}
        onBreakStart = {}
        onBreakEnd = {}
        onStop = {}
        onPause = {}
        
    }
    
    init(sessionDuration: TimeInterval, breakCount: Int, breakDuration: TimeInterval, update: @escaping () -> (), onSessionEnd: @escaping () -> (), onBreakStart: @escaping () -> (), onBreakEnd: @escaping () -> (),  onStop: @escaping () -> (), onPause: @escaping () -> ()) {
        
        self.update = update
        self.onSessionEnd = onSessionEnd
        self.onBreakStart = onBreakStart
        self.onBreakEnd = onBreakEnd
        self.onStop = onStop
        self.onPause = onPause
        self.totalBreaks = breakCount
        
        sessionTimer = PausableTimer()
        sessionTimer.duration = sessionDuration
        timeToBreakTimer = PausableTimer()
        timeToBreakTimer.duration = sessionDuration / Double(breakCount + 1 ) - breakDuration / 2.0
        breakTimer = PausableTimer()
        breakTimer.duration = breakDuration
        
        breakCounter = 0
        
    }
    
    func start() {
        //let breakTimerDuration = sessionDuration / Double(breakCount + 1 ) - breakDuration / 2.0
        //sessionTimer = PausableTimer(duration: sessionDuration, update: self.update, onPause: self.onPause, onEnd: self.onEnd)
        
        sessionTimer.update = self.update
        sessionTimer.onPause = self.onPause
        sessionTimer.onEnd = { self.stop() ; self.onSessionEnd()}
        breakCounter = 0
        
        timeToBreakTimer.update = {}
        timeToBreakTimer.onPause = {}
        
        timeToBreakTimer.onEnd = {
            self.onBreakStart()
            self.breakCounter += 1
            
            if(self.breakRemaining()) {
                self.breakTimer.onEnd = {
                    self.onBreakEnd()
                    self.breakTimer.stop()
                    self.timeToBreakTimer.stop()
                    self.timeToBreakTimer.start()
                }
            } else {
                self.breakTimer.onEnd = {
                    self.onBreakEnd()
                    self.breakTimer.stop()
                }
            }
            
            self.breakTimer.start()
            
        }
        
        
        
        sessionTimer.start()
        timeToBreakTimer.start()
        
    }
    
    @objc private func restartBreakTimer() {
        self.timeToBreakTimer.start()
    }
    
    func stop() {
        sessionTimer.stop()
        timeToBreakTimer.stop()
        breakTimer.stop()
        
    }
    
    func resume() {
        sessionTimer.resume()
        timeToBreakTimer.resume()
    }
    
    func pause() {
        sessionTimer.pause()
        timeToBreakTimer.pause()
        
    }
    
    func started() -> Bool {
        return sessionTimer.started()
    }
    
    func isRunning() -> Bool {
        return sessionTimer.isRunning
    }
    
    func breakInProgress() -> Bool {
        return breakTimer.isRunning
    }
    
    func breakRemaining() -> Bool {
        return breakCounter < totalBreaks
    }

    
    
}
