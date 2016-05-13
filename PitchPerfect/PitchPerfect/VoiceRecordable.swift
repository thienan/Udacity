//
//  VoiceRecordable.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-10.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

protocol VoiceRecordable {
    
    var pathToRecording: NSURL? { get }
    var delegate: Any? { get set }
    
    init? (fileName: String)
    
    func prepareToRecord() -> Bool
    func record() -> RecordPermission
    func stopRecording() -> Bool
    func recording() -> Bool
}