//
//  HomeVC.swift
//  FolledoRealVoiceMemo
//
//  Created by Macbook Pro 15 on 8/31/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import Speech
import NaturalLanguage //Added for tokenizing our transcribed words

class HomeVC: UIViewController {
    
//MARK: IBOutlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var speechTextView: UITextView!
    @IBOutlet weak var languageControl: UISegmentedControl!
    
    
//MARK: Properties
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //14mins
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    var lang: String = "en-US"
    
    var speechToText: String = ""
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupSpeechRecognition()
        
    }
    
//MARK: Methods
    func setupSpeechRecognition() {
        
        recordButton.isEnabled = false //disable recordButton
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang)) //assign speechRecognizer's language
        SFSpeechRecognizer.requestAuthorization { [unowned self] (authStatus) in //request authorization, if we have authorization the we enable the recordButton
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
//                self.record
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition is")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition is restricted on this device")
                
            @unknown default:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            }
            
            OperationQueue.main.addOperation {
                self.recordButton.isEnabled = isButtonEnabled //enable our recordButton depending on the value of isButtonEnabled
            }
        }
    }
    
    func changeLanguage() {
        switch languageControl.selectedSegmentIndex { //switch between languages depending on the selected segmentIndex
        case 0:
            lang = "en-US"
            break
        case 1:
            lang = "fr-FR"
            break
        case 2:
            lang = "de-DE"
            break
        case 3:
            lang = "es-ES"
            break
        case 4:
            lang = "it-IT"
            break;
        default:
            lang = "en-US"
            break
        }
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance() //15mins start the audio session and set its properties
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() //initialize recognitionRequest
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true // shouldReportPartialResults = a Boolean value that indicates whether you want intermediate results returned for each utterance.
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in //recognitionTask = Executes the speech recognition request and delivers the results to the specified handler block.
            
            var isFinal = false
            
            if result != nil { //if we have results
                let transcription = result!.bestTranscription.formattedString //The transcription with the highest confidence level.
//                self.speechTextView.text = transcription
                isFinal = result!.isFinal //isFinal = a Boolean value that indicates whether speech recognition is complete and whether the transcriptions are final.
//                print("\(isFinal) = \(transcription)") //turns true when we click stop recording.
                self.speechToText = transcription //assign transcribed words to speechToText
                
//NATURAL LANGUAGE PROCESSING beginning
                let tagger = NLTagger(tagSchemes: [.lexicalClass])
                tagger.string = transcription
                var result = ""
                
                tagger.enumerateTags(in: transcription.startIndex ..< transcription.endIndex, unit: .word, scheme: .lexicalClass, options: [.omitPunctuation, .omitWhitespace], using: { (tag, range) -> Bool in //omit means to exclude //enumerateTags = Enumerates over a given range of the string for a particular unit and calls the specified block for each tag.
                    /* Parameters
                    
                    range
                    The range to analyze.
                    unit
                    The linguistic unit. .word tokenize every word
                    The tag scheme. For possible values, see NLTagScheme.
                    options
                    The linguistic tagger options to use. For possible values, see NLTagger.Options.
                    block
                    The block to apply to ranges of the string.
                    The block takes the following arguments:
                    tag
                    The located linguistic tag.
                    tokenRange
                    The range of the linguistic tag.
                    stop
                    A reference to a Boolean value. The block can set the value to true to stop further processing of the set. The stop argument is an out-only argument. You should only ever set this Boolean to true within the block. */
                    if let lexicalTag = tag {
                        result += transcription[range] + " = [\(lexicalTag.rawValue)]\n"
                    }
                    self.speechTextView.text = result
                    return true
                })
                print(result)
            }
            
            if error != nil || isFinal {
                self.audioEngine.inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in

            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        speechTextView.text = "Say something, I'm listening!"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) { //tells the delegate that the availability of its associated speech recognizer changed.
        recordButton.isEnabled = available
    }
    
//MARK: IBActions
    @IBAction func recordButtonTapped(_ sender: Any) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning { //if we tap on the button while it's audioEnging is running, then stop recording
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Start Recording", for: .normal)
        } else { //if audioEngine is not runnign then start recoding
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    @IBAction func languageControlTapped(_ sender: Any) {
        changeLanguage()
    }
    
    

}
