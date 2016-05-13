//
//  PlayAudio.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-11.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import AVFoundation

/* Portions of this code were adapted from:
 
 Udacity (2016) PitchPerfect (Audio playback with effects).
 Available at: https://www.udacity.com (Accessed: 11 May 2016) */

final class PlayAudio: PlayableAudio {
    private var audioFile: AVAudioFile!
    private var audioEngine: AVAudioEngine!
    private var audioPlayerNode: AVAudioPlayerNode!
    private var stopTimer: NSTimer!
    weak var delegate: PlayableAudioDelegate?
    
    // MARK: Init
    
    required init?(audioFilePath path: NSURL) {
        guard let audioFile = try? AVAudioFile(forReading: path) else {
            return nil
        }
        self.audioFile = audioFile
    }
    
    // MARK: Audio Functions
    
    func play(rate rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) throws {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)

        // Node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attachNode(changeRatePitchNode)
        
        // Node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.MultiEcho1)
        audioEngine.attachNode(echoNode)
        
        // Node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.Cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attachNode(reverbNode)
        
        // Connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // Schedule to play and start the engine
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // Schedule a stop timer for when audio finishes playing
            self.stopTimer = NSTimer(timeInterval: delayInSeconds, target: self, selector: #selector(PlayAudio.stop), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.stopTimer, forMode: NSDefaultRunLoopMode)
        }
        
        try audioEngine.start()
        
        delegate?.willStartPlaying()
        
        // Play the recording
        audioPlayerNode.play()
    }
    
    @objc func stop() {
        if let stopTimer = self.stopTimer {
            stopTimer.invalidate()
        }
        
        delegate?.didFinishPlaying()
        
        if let audioPlayerNode = self.audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let audioEngine = self.audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
}