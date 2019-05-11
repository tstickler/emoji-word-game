//
//  AudioPlayer.swift
//  emojiWords
//
//  Created by Tyler Stickler on 5/9/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import AVFoundation

class AudioPlayer {
    static var shared = AudioPlayer()
    private var audioPlayer: AVAudioPlayer?
    
    func startMusic(musicTitle: String, ext: String) {
        // Find our music file
        let path = Bundle.main.path(forResource: musicTitle, ofType: ext)!
        let url = URL(fileURLWithPath: path)
        
        var musicPlayer = AVAudioPlayer()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Play the music
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.numberOfLoops = 1
            musicPlayer.volume = 0
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            if User.shared.prefersSoundEffects {
                musicPlayer.setVolume(0.3, fadeDuration: 1.0)
            }
            
            audioPlayer = musicPlayer
        } catch {
            print(error)
        }
    }
    
    func playSoundEffect(soundEffect sound: String, ext: String) {
        if !User.shared.prefersSoundEffects {
            return
        }
        
        if let soundURL = Bundle.main.url(forResource: sound, withExtension: ext) {
            var soundID: SystemSoundID = 1
            
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            
            AudioServicesPlaySystemSound(soundID)
        }
    }

}

