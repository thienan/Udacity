//
//  PlayableAudioDelegate.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-11.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import Foundation

/* Suragch (2015) Delegates in swift?
 Available at: http://stackoverflow.com/a/33549729 (Accessed: 11 May 2016) */

protocol PlayableAudioDelegate: class {
    func willStartPlaying()
    func didFinishPlaying()
}