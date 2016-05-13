//
//  PlayableAudio.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-11.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayableAudio {
    var delegate: PlayableAudioDelegate? { get set }
    init?(audioFilePath: NSURL)
    func play(rate rate: Float?, pitch: Float?, echo: Bool, reverb: Bool) throws
    func stop()
}