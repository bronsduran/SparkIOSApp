//
//  AudioView.swift
//  Spark1.0
//
//  Created by Lucas Throckmorton on 2/29/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import UIKit
import AVKit

class AudioView: UIView, EZAudioPlayerDelegate /*, EZMicrophoneDelegate, EZRecorderDelegate*/ {
    
    let urlString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/tempVoiceFile.caf")
    
    var soundFilePath: NSURL!
    var player: EZAudioPlayer!
//    var recorder: EZRecorder!
//    var microphone: EZMicrophone!
    
    var state: State! {
        didSet {
            if player.audioFile == nil {
                return
            }
            switch state! {
            case .playing:
//                recorder?.delegate = nil
//                audioPlot.hidden = false
//                recordPlot.hidden = true
                actionButton.setImage(UIImage(named: "videoStopButton"), forState: .Normal)
//                audioPlot.clear()
                player.play()
                
            case .stopped:
//                recorder?.delegate = nil
//                audioPlot.hidden = false
//                recordPlot.hidden = true
                actionButton.setImage(UIImage(named: "playButton"), forState: .Normal)
                
//                player.pause()
                loadFile()
                
            case .recording:
//                audioPlot.hidden = true
//                recordPlot.hidden = false
                actionButton.setImage(UIImage(named: "recordStopButton"), forState: .Normal)
//                recordPlot.clear()
                
                // set up recorder
//                microphone.startFetchingAudio()
//                recorder = EZRecorder(URL: soundFilePath, clientFormat: microphone.audioStreamBasicDescription(), fileType: EZRecorderFileType.M4A, delegate: self)
                
            case .stoppedRecording:
                break
//                microphone.stopFetchingAudio()
//                recorder?.closeAudioFile()
//                
//                player.audioFile = EZAudioFile(URL:soundFilePath)
//                state = .stopped
//                recorder?.delegate = nil
            }
        }
    }
    
    func loadFile() {
        self.player.audioFile = EZAudioFile(URL: soundFilePath)
        self.player.audioFile.getWaveformDataWithCompletionBlock({
            waveformData, length in
        
            if waveformData == nil {
                return
            }
        
            self.audioPlot.updateBuffer((waveformData as UnsafeMutablePointer<UnsafeMutablePointer<Float>>).memory, withBufferSize: UInt32(length))
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    @IBOutlet weak var audioPlot: EZAudioPlot!
//    @IBOutlet weak var recordPlot: EZAudioPlotGL!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBAction func actionButton(sender: UIButton) {
        switch state! {
        case .playing: state = .stopped
        case .stopped: state = .playing
        case .recording: state = .stoppedRecording
        default: break
        }
    }
    
    let height: CGFloat = 50
    
    class func instanceFromNib() -> AudioView {
        let view = UINib(nibName: "AudioView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AudioView
        
        view.backgroundColor = UIColor.clearColor()
        view.setupPlayer()
        view.layer.masksToBounds = true
        
        view.state = .stopped
        
        view.soundFilePath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/tempVoiceFile.caf"))
        
        return view
    }
    
    
    
    // must get called after self has been added to superview
    func populateView() {
        if let superview = superview {
            self.frame = CGRectMake(0, 0, superview.frame.width, height)
        }
    }
    
    // Set up Audio Player
    func setupPlayer() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            
//            recordPlot.backgroundColor = UIColor.clearColor()
//            recordPlot.color = UIColor.whiteColor()
//            recordPlot.plotType = EZPlotType.Rolling
//            recordPlot.shouldFill = true
//            recordPlot.shouldMirror = true
            
//            microphone = EZMicrophone(delegate: self)
            
            actionButton.hidden = true
            audioPlot.backgroundColor = UIColor.clearColor()
            audioPlot.color = UIColor.whiteColor()
            audioPlot.plotType = EZPlotType.Rolling
            audioPlot.shouldFill = true
            audioPlot.shouldMirror = true
            audioPlot.gain = 2.5
            audioPlot.pointCount = 30
            
            player = EZAudioPlayer(delegate: self)
            
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch {}
        
    }
    
    // Set up Audio Recording
    
    func withMoment(moment: Moment) -> Bool {
        
        moment.getFileNamed("voiceData") { (data: NSData?) -> Void in
            
            NSFileManager.defaultManager().createFileAtPath(
                self.urlString, contents: data, attributes: nil)
            
            self.loadFile()
            
            self.actionButton.hidden = false
            self.state = .stopped
        }
        
        return false
    }
    
    func setupAsRecorder() {
        state = .recording
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidReachEndOfFile:", name: EZAudioPlayerDidReachEndOfFileNotification, object: player)
    }

    // MARK: - delegates
    
    // EZAudioPlayer
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        })
    }
    
//    // EZMicrophone
//    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
//        dispatch_async(dispatch_get_main_queue(), {
//            self.recordPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
//        })
//    }
//    
//    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
//        self.recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
//    }
//    
//    // EZRecorder
//    func recorderDidClose(recorder: EZRecorder!) {
//        recorder.delegate = nil
//    }
//    
//    func recorderUpdatedCurrentTime(recorder: EZRecorder!) {
//        return
//    }
    
    
    // MARK: - State Changes
    
    enum State {
        case playing
        case stopped
        case recording
        case stoppedRecording
    }
    
    func playerDidReachEndOfFile(notification: NSNotification) {
        state = .stopped
    }
    

    
}
