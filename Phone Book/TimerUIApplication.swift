//
//  TimerUIApplication.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 11/20/17.
//  Copyright © 2017 UPenn. All rights reserved.
//

import Foundation
import UIKit

class TimerUIApplication : UIApplication {
    
    static let ApplicationDidTimeoutNotification = "AppTimeout"
    static private var timeoutInSeconds: TimeInterval {
        // TODO: Return cached setting from UserDefaults
        return 2*60 // 2 mins for timeout
    }
    static private var idleTimer: Timer?
    
    // Listen for any touch. If the screen receives a touch, the timer is reset.
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if TimerUIApplication.idleTimer != nil {
            TimerUIApplication.resetIdleTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches {
                if touch.phase == .began {
                    TimerUIApplication.resetIdleTimer()
                }
            }
        }
    }
    
    // Resent the timer because there was user interaction.
    static func resetIdleTimer() {
        self.invalidateActiveTimer()
        
        TimerUIApplication.idleTimer = Timer.scheduledTimer(timeInterval: TimerUIApplication.timeoutInSeconds, target: self, selector: #selector(TimerUIApplication.idleTimerExceeded), userInfo: nil, repeats: false)
    }
    
    static func invalidateActiveTimer() {
        if let idleTimer = TimerUIApplication.idleTimer {
            idleTimer.invalidate()
        }
    }
    
    // If the timer reaches the limit as defined in timeoutInSeconds, post this notification.
    static func idleTimerExceeded() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TimerUIApplication.ApplicationDidTimeoutNotification), object: nil)
    }
    
    static func updateTimeoutInterval(intervalSeconds: TimeInterval) {
        // TODO: Update timeoutInterval in UserDefaults w/ intervalSeconds
    }
}
