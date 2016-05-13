//
//  RecordAudioViewController.swift
//  PitchPerfect
//
//  Created by Ryan Harri on 2016-05-05.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, SegueHandlerType, Alertable {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var tapToRecordLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    var voiceRecorder: VoiceRecordable?
    
    enum SegueIdentifier: String {
        case ShowPlayAudio = "showPlayAudio"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Record", comment: "Record")
                
        configureUI(whenRecordingIs: false)
        
        if var voiceRecorder = self.voiceRecorder {
            voiceRecorder.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func configureUI(whenRecordingIs recording: Bool) {
        if recording {
            recordButton.enabled = false
            tapToRecordLabel.text = NSLocalizedString("Recording", comment: "Recording")
            stopButton.enabled = true
        } else {
            recordButton.enabled = true
            tapToRecordLabel.text = NSLocalizedString("Tap To Record", comment: "Tap To Record")
            stopButton.enabled = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let voiceRecorder = self.voiceRecorder else {
            displayAlert(nil, message: NSLocalizedString("Unable to retrieve location of recording.", comment: "Unable to retrieve location of recording."))
            return
        }
        
        guard let segueIdentifier = segueIdentifierForSegue(segue) else {
            displayAlert(nil, message: NSLocalizedString("Unable to display play screen.", comment: "Unable to display play screen."))
            return
        }
        
        switch segueIdentifier {
        case .ShowPlayAudio:
            let playAudioViewController = segue.destinationViewController as! PlayAudioViewController
            playAudioViewController.pathToRecording = voiceRecorder.pathToRecording
        }
    }
    
    @IBAction func stopRecording(sender: AnyObject) {
        guard let voiceRecorder = self.voiceRecorder else {
            displayAlert(nil, message: NSLocalizedString("Unable to stop the recording. Please try again.", comment: "Unable to stop the recording. Please try again."))
            return
        }
        
        voiceRecorder.stopRecording()
        configureUI(whenRecordingIs: false)
    }
    
    @IBAction func record(sender: AnyObject) {
        guard let voiceRecorder = self.voiceRecorder else {
            displayAlert(nil, message: NSLocalizedString("Unable to begin recording. Please try again.", comment: "Unable to begin recording. Please try again."))
            return
        }
        
        voiceRecorder.prepareToRecord()
        let permission = voiceRecorder.record()
        
        switch permission {
        case .Allowed:
            configureUI(whenRecordingIs: true)
        case .NotAllowed:
            let titleText = NSLocalizedString("Permission Required", comment: "Permission Required")
            let message = NSLocalizedString("Pitch Perfect requires use of the microphone. You can review your privacy settings by going to Settings > Privacy > Microphone.", comment: "Pitch Perfect requires use of the microphone. You can review your privacy settings by going to Settings > Privacy > Microphone.")
            displayAlert(titleText, message: message)
        case .Unknown:
            break
        }
    }
}

extension RecordAudioViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        performSegueWithIdentifier(.ShowPlayAudio, sender: nil)
    }
}

