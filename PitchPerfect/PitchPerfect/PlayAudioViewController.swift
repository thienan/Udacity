//
//  PlayAudioViewController.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-10.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit

class PlayAudioViewController: UIViewController, Alertable, PlayableAudioDelegate {
    
    var pathToRecording: NSURL?
    var playAudio: PlayableAudio?
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var tieFighterButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Play", comment: "Play")
        configureUI(whenPlayingIs: false)
        
        guard let pathToRecording = self.pathToRecording, let playAudio = PlayAudio(audioFilePath: pathToRecording) else {
            displayAlert(nil, message: NSLocalizedString("Unable to create audio file.", comment: "Unable to create audio file."))
            return
        }
        
        self.playAudio = playAudio
        self.playAudio?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Use small button images for compact height / compact width, otherwise use the normal image size
        if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Compact && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            snailButton.setImage(UIImage(assetIdentifier: .SnailButtonSmall), forState: UIControlState.Normal)
            rabbitButton.setImage(UIImage(assetIdentifier: .RabbitButtonSmall), forState: UIControlState.Normal)
            chipmunkButton.setImage(UIImage(assetIdentifier: .ChipmunkButtonSmall), forState: UIControlState.Normal)
            tieFighterButton.setImage(UIImage(assetIdentifier: .TIEFighterButtonSmall), forState: UIControlState.Normal)
            echoButton.setImage(UIImage(assetIdentifier: .EchoButtonSmall), forState: UIControlState.Normal)
            reverbButton.setImage(UIImage(assetIdentifier: .ReverbButtonSmall), forState: UIControlState.Normal)
            stopButton.setImage(UIImage(assetIdentifier: .StopButtonSmall), forState: UIControlState.Normal)
        } else {
            snailButton.setImage(UIImage(assetIdentifier: .SnailButton), forState: UIControlState.Normal)
            rabbitButton.setImage(UIImage(assetIdentifier: .RabbitButton), forState: UIControlState.Normal)
            chipmunkButton.setImage(UIImage(assetIdentifier: .ChipmunkButton), forState: UIControlState.Normal)
            tieFighterButton.setImage(UIImage(assetIdentifier: .TIEFighterButton), forState: UIControlState.Normal)
            echoButton.setImage(UIImage(assetIdentifier: .EchoButton), forState: UIControlState.Normal)
            reverbButton.setImage(UIImage(assetIdentifier: .ReverbButton), forState: UIControlState.Normal)
            stopButton.setImage(UIImage(assetIdentifier: .StopButtonLarge), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func handleAction(sender: AnyObject) {
        guard let button = sender as? UIButton, let buttonType = ButtonType(rawValue: button.tag), let playAudio = self.playAudio else {
            return
        }
        
        do {
            switch buttonType {
            case .Snail:
                try playAudio.play(rate: 0.5, pitch: nil, echo: false, reverb: false)
            case .Rabbit:
                try playAudio.play(rate: 1.5, pitch: nil, echo: false, reverb: false)
            case .Chipmunk:
                try playAudio.play(rate: nil, pitch: 1000, echo: false, reverb: false)
            case .TIEFighter:
                try playAudio.play(rate: nil, pitch: -1000, echo: false, reverb: false)
            case .Echo:
                try playAudio.play(rate: nil, pitch: nil, echo: true, reverb: false)
            case .Reverb:
                try playAudio.play(rate: nil, pitch: nil, echo: false, reverb: true)
            case .Stop:
                stop()
            }
        } catch {
            configureUI(whenPlayingIs: false)
            displayAlert(nil, message: NSLocalizedString("Unable to play sound.", comment: "Unable to play sound."))
        }
    }
    
    func stop() {
        guard let playAudio = self.playAudio else {
            displayAlert(nil, message: NSLocalizedString("Unable to stop playing sound.", comment: "Unable to stop playing sound."))
            return
        }
        playAudio.stop()
    }
    
    func configureUI(whenPlayingIs playing: Bool) {
        if playing {
            snailButton.enabled = false
            rabbitButton.enabled = false
            chipmunkButton.enabled = false
            tieFighterButton.enabled = false
            echoButton.enabled = false
            reverbButton.enabled = false
            stopButton.enabled = true
        } else {
            snailButton.enabled = true
            rabbitButton.enabled = true
            chipmunkButton.enabled = true
            tieFighterButton.enabled = true
            echoButton.enabled = true
            reverbButton.enabled = true
            stopButton.enabled = false
        }
    }
    
    func willStartPlaying() {
        configureUI(whenPlayingIs: true)
    }
    
    func didFinishPlaying() {
        configureUI(whenPlayingIs: false)
    }
}
