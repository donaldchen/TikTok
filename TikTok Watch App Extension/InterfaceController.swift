//
//  InterfaceController.swift
//  TikTok Watch App Extension
//
//  Created by Donald Chen on 12/14/15.
//  Copyright © 2015 MegaUkulele. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var pulseImage: WKInterfaceImage!
    @IBOutlet weak var playPauseButton: WKInterfaceButton!
    @IBOutlet weak var tapButton: WKInterfaceButton!
    @IBOutlet weak var bpmPicker: WKInterfacePicker!
    
    let maxBpm = 200
    let minBpm = 30
    let pulseWidth: CGFloat = 100.0
    let pulseHeight: CGFloat = 100.0
    let initialBpm: Int = 120
    var playing: Bool = false
    var completedLastAnimation: Bool = true
    var numbers: [String] = []
    var animationTime: Double = 0.25
    
    //tap BPM variables
    let timeout = 2.000
    var previousTime = 0.000
    var tapTimes: [Double] = []
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("print works!")
        
        // Configure interface objects here.
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initBpmPicker()
        setGlowingRate(initialBpm)
    }
    
    func initBpmPicker() {
        for bpm in minBpm...maxBpm {
            numbers.append(String(bpm))
        }
        let pickerItems: [WKPickerItem] = numbers.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0
            return pickerItem
        }
        bpmPicker.setItems(pickerItems)
        bpmPicker.setSelectedItemIndex(numbers.indexOf(String(initialBpm))!)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func playPauseTouched() {
        playing = !playing
        if playing {
            playPauseButton.setBackgroundImageNamed("pause_button")
            if completedLastAnimation {
                shrink()
            }
        } else {
            playPauseButton.setBackgroundImageNamed("play_button")
        }
    }
    
    @IBAction func tapTouched() {
        let currentTime = NSDate().timeIntervalSince1970
        if currentTime - previousTime > timeout {
            tapTimes.removeAll()
        }
        tapTimes.append(currentTime)
        previousTime = currentTime
        
        if tapTimes.count > 1 {
            var last = tapTimes.removeAtIndex(0)
            var differences: [Double] = []
            for tapTime in tapTimes {
                differences.append(tapTime - last)
                last = tapTime
            }
            var sum = 0.0
            
            for difference in differences {
                sum += difference
            }
            let average = sum / Double(differences.count)
            let bpm = normalizeBpm(Int(60.0 / average))
            setGlowingRate(Int(bpm))
            bpmPicker.setSelectedItemIndex(numbers.indexOf(String(bpm))!)
        }
        
    }
    
    func normalizeBpm(bpm: Int) -> Int {
        if bpm > maxBpm {
            return maxBpm
        } else if bpm < minBpm {
            return minBpm
        } else {
            return bpm
        }
    }
    
    func shrink() {
        if playing {
            animateWithDuration(animationTime, animations: {
                self.pulseImage.setHeight(20.0)
                self.pulseImage.setWidth(20.0)
                WKInterfaceDevice.currentDevice().playHaptic(.Click)
                }, completion: {(finished: Bool) -> Void in
                    self.completedLastAnimation = false
                    self.grow()
            })
        }
    }
    
    func grow() {
        animateWithDuration(animationTime, animations: {
            self.pulseImage.setWidth(self.pulseWidth)
            self.pulseImage.setHeight(self.pulseHeight)
            }, completion: {(finished: Bool) -> Void in
                self.completedLastAnimation = true
                self.shrink()
        })
    }
    
    func setGlowingRate(bpm: Int) {
        animationTime = 1.0 / Double(bpm) * 60 * 0.5
    }
    
    @IBAction func pickerSelectedItemChanged(value: Int) {
        let bpm = Int(numbers[value])
        print(numbers[value])
        setGlowingRate(bpm!)
    }
    

    
}

// allows animateWithDuration function to take completion block on watchOS2
extension WKInterfaceController {
    func animateWithDuration(duration: NSTimeInterval, animations: () -> Void, completion: ((Bool) -> Void)?) {
        animateWithDuration(duration, animations: animations)
        let completionDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
        dispatch_after(completionDelay, dispatch_get_main_queue()) {
            completion?(true)
        }
    }
}
