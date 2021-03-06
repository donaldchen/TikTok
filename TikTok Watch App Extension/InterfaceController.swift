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
    @IBOutlet weak var pulseGroup: WKInterfaceGroup!
    
    let maxBpm = 200
    let minBpm = 30
    var pulseWidth: CGFloat = 94.0
    var pulseHeight: CGFloat = 94.0
    let initialBpm: Int = 120
    var playing: Bool = false
    var completedLastAnimation: Bool = true
    var numbers: [String] = []
    var animationTime: Double = 0.25
    var keepTappingPromptTime: Double = 3.0
    let bounds = WKInterfaceDevice.currentDevice().screenBounds
    let smallScreenWidth: CGFloat = 136.0
    // 38mm: (0.0, 0.0, 136.0, 170.0)
    // 42mm: (0.0, 0.0, 156.0, 195.0)
    let timeAdjustment: Double = 0.015
    
    //tap BPM variables
    let timeout = 2.000
    var previousTime = 0.000
    var tapTimes: [Double] = []
    var tapBeats: [Double] = []
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        initBpmPicker()
        setGlowingRateFromBpm(initialBpm)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initPlayPauseButton()
        initPulse()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        // turn off vibration when screen is off
        if playing {
            playing = false
        }
    }
    
    func initPulse() {
        if self.bounds.width > self.smallScreenWidth {
            pulseWidth = 94.0
            pulseHeight = 94.0
        } else {
            pulseWidth = 76.0
            pulseHeight = 76.0
        }
        pulseImage.setWidth(pulseWidth)
        pulseImage.setHeight(pulseHeight)
        pulseGroup.setWidth(pulseWidth)
        pulseGroup.setHeight(pulseHeight)
    }
    
    func initPlayPauseButton() {
        playPauseButton.setBackgroundImageNamed("play_button")
    }
    
    func initBpmPicker() {
        for bpm in minBpm...maxBpm {
            numbers.append(String(bpm))
        }
        let pickerItems: [WKPickerItem] = numbers.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0
            pickerItem.caption = "BPM"
            return pickerItem
        }
        bpmPicker.setItems(pickerItems)
        bpmPicker.setSelectedItemIndex(numbers.indexOf(String(initialBpm))!)
        bpmPicker.focus()
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
            tapBeats.removeAll()
        }
        tapTimes.append(currentTime)
        tapBeats.append(Double(tapBeats.count))
        previousTime = currentTime

        if tapTimes.count > 1 {
            // uses simple linear regression to calculate the time per beat and then the BPM
            let avgTapTime = tapTimes.reduce(0){$0 + $1} / Double(tapTimes.count)
            let avgNumTaps = tapBeats.reduce(0){$0 + $1} / Double(tapBeats.count)
            
            
            var numerator: Double = 0.0
            var denominator: Double = 0.0
            
            for i in 1...tapTimes.count - 1 {
                numerator += (tapBeats[i] - avgNumTaps) * (tapTimes[i] - avgTapTime)
                denominator += (tapBeats[i] - avgNumTaps) * (tapBeats[i] - avgNumTaps)
            }
            
            let secondsPerBeat = numerator / denominator
            let bpm = normalizeBpm(Int(60.0 / secondsPerBeat))
            setGlowingRateFromBpm(bpm)
            bpmPicker.setSelectedItemIndex(numbers.indexOf(String(bpm))!)
        }
        
        // temporarily changes the prompt from "Tap to Set BPM" to "Keep Tapping"
        if tapBeats.count < 2 {
            animateWithDuration(keepTappingPromptTime, animations: {
                self.tapButton.setTitle("Keep Tapping")
                }, completion: {(finished: Bool) -> Void in
                    self.tapButton.setTitle("Tap to Set BPM")
            })
        }
    }
    
    @IBAction func setGreenPulse() {
        pulseImage.setImageNamed("pulse_tok_green")
    }
    
    @IBAction func setBluePulse() {
        pulseImage.setImageNamed("pulse_aquaman_blue")
    }
    
    @IBAction func setRosePulse() {
        pulseImage.setImageNamed("pulse_gogenta")
    }
    
    @IBAction func setOrangePulse() {
        pulseImage.setImageNamed("pulse_hound_orange")
    }
    
    
    @IBAction func pickerSelectedItemChanged(value: Int) {
        let bpm = Int(numbers[value])
        setGlowingRateFromBpm(bpm!)
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
                self.pulseImage.setHeight(30.0)
                self.pulseImage.setWidth(30.0)
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
    
    func setGlowingRateFromBpm(bpm: Int) {
        animationTime = 1.0 / Double(bpm) * 60 * 0.5 - timeAdjustment
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
