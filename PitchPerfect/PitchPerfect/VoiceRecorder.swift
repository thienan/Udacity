//
//  VoiceRecorder.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-10.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import AVFoundation

// A thin wrapper class around the AVAudioRecorder Class (AVFoundation)
final class VoiceRecorder: VoiceRecordable {
    
    private var fileName: String?
    private var audioRecorder: AVAudioRecorder?
        
    private var directoryForRecording: NSURL? {
        let fileManager = NSFileManager.defaultManager()
        
        // Default to the Document directory
        if let directoryForRecording = try? fileManager.URLForDirectory(NSSearchPathDirectory.DocumentDirectory,
                                                                        inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false) {
            return directoryForRecording
        }
        return nil
    }
    
    var pathToRecording: NSURL? {
        if let directoryForRecording = self.directoryForRecording, let fileName = self.fileName {
            return directoryForRecording.URLByAppendingPathComponent(fileName)
        }
        return nil
    }
    
    var delegate: Any? {
        get {
            if let audioRecorder = self.audioRecorder {
                return audioRecorder.delegate
            }
            return nil
        }
        set {
            if let audioRecorder = self.audioRecorder {
                audioRecorder.delegate = newValue as? AVAudioRecorderDelegate
            }
        }
    }
    
    required init?(fileName: String) {
        if fileName.isEmpty {
            return nil
        }
        
        self.fileName = fileName
        
        if let pathToRecording = self.pathToRecording,
            let audioRecorder = try? AVAudioRecorder.init(URL: pathToRecording, settings: [:]), let _ = try? AVAudioSession.sharedInstance().setActive(true) {
            
            self.audioRecorder = audioRecorder
        
        } else {
            return nil
        }
    }
    
    func prepareToRecord() -> Bool {
        guard let audioRecorder = self.audioRecorder else {
            return false
        }
        return audioRecorder.prepareToRecord()
    }
    
    func record() -> RecordPermission {
        let audioSession = AVAudioSession.sharedInstance()
        
        var permission: RecordPermission = .Unknown
        if audioSession.recordPermission() == AVAudioSessionRecordPermission.Denied || audioSession.recordPermission() == AVAudioSessionRecordPermission.Undetermined {
            audioSession.requestRecordPermission() {
                granted in
                
                if !granted {
                    permission = .NotAllowed
                }
            }
        } else {
            permission = .Allowed
        }
        
        if permission == .Allowed {
            if let audioRecorder = self.audioRecorder, let _ = try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord) {
                audioRecorder.meteringEnabled = true
                audioRecorder.record()
            }
        }
        
        return permission
    }
    
    func stopRecording() -> Bool {
        guard let audioRecorder = self.audioRecorder else {
            return false
        }
        
        audioRecorder.stop()
        
        guard let _ = try? AVAudioSession.sharedInstance().setActive(false) else {
            return false
        }
        
        return true
    }
    
    func recording() -> Bool {
        guard let audioRecorder = self.audioRecorder  else {
            return false
        }
        return audioRecorder.recording
    }
}