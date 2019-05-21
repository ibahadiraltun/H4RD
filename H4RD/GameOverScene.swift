//
//  GameOverScene.swift
//  H4RD
//
//  Created by Bahadir Altun on 9.07.2018.
//  Copyright © 2018 Bahadir Altun. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import FirebaseDatabase

class GameOverScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    let userDefaults = UserDefaults.standard
    
    private var scoreLabel : SKLabelNode?
    private var highScoreLabel : SKLabelNode?
    private var playAgainLabel : SKLabelNode?
    private var mainMenuLabel : SKLabelNode?
    private var shareLabel : SKLabelNode?
    
    private var lastUpdateTime : TimeInterval = 0
    
    var buttonSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "buttonSound", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    
    var soundStatus : Bool?
    var highScore : Double?
    var currentScore : Double?
    
    var ref : DatabaseReference?
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        self.currentScore = StartScene.score

        ref = Database.database().reference()
        
        soundStatus = userDefaults.bool(forKey: "SOUNDSTATUS")
        highScore = userDefaults.double(forKey: "HIGHSCORE")
        
        try! audioPlayer = AVAudioPlayer(contentsOf: buttonSound as URL)
        audioPlayer.prepareToPlay()

        self.playAgainLabel = self.childNode(withName: "//playAgainLabel") as? SKLabelNode
        self.mainMenuLabel = self.childNode(withName: "//mainMenuLabel") as? SKLabelNode
        self.shareLabel = self.childNode(withName: "//shareLabel") as? SKLabelNode
        
        perform(#selector(showScoreLabel), with: nil, afterDelay: 0.7)
        perform(#selector(showHighScoreLabel), with: nil, afterDelay: 0)
    }
    
    @objc func showScoreLabel() {
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        self.scoreLabel?.text = String(format: "%.1f", StartScene.score)
        self.scoreLabel?.alpha = 1
        
        let numberOfGames = userDefaults.integer(forKey: "NUMBEROFGAMES")
        var averageScore = userDefaults.double(forKey: "AVERAGESCORE")
        averageScore = (Double(numberOfGames) * averageScore + StartScene.score) / Double(numberOfGames + 1)
        
        userDefaults.set(numberOfGames + 1, forKey: "NUMBEROFGAMES")
        userDefaults.set(averageScore, forKey: "AVERAGESCORE")

        ref?.child("users").child(GameViewController.username!)
            .child("numberOfGames").setValue(userDefaults.integer(forKey: "NUMBEROFGAMES"))
        ref?.child("users").child(GameViewController.username!)
            .child("averageScore").setValue(userDefaults.double(forKey: "AVERAGESCORE"))

    }

    @objc func showHighScoreLabel() {
        print(StartScene.score, highScore!)
        self.highScoreLabel = self.childNode(withName: "//highScoreLabel") as? SKLabelNode
        if StartScene.score > highScore! {
            self.highScoreLabel?.text = String(format: "New High Score: %.1f !!!", StartScene.score)
            userDefaults.set(StartScene.score, forKey: "HIGHSCORE")
            ref?.child("users").child(GameViewController.username!)
                .child("highScore").setValue(userDefaults.double(forKey: "HIGHSCORE"))
        } else {
            self.highScoreLabel?.text = String(format: "High Score: %.1f", highScore!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let current_touch = touches.first
        if (self.playAgainLabel?.contains((current_touch?.location(in: self))!))!
            || (self.mainMenuLabel?.contains((current_touch?.location(in: self))!))!
            || (self.shareLabel?.contains((current_touch?.location(in: self))!))! {
            if soundStatus! {
                audioPlayer.play()
            }
        }
        if (self.playAgainLabel?.contains((current_touch?.location(in: self))!))! {
            print("TAPPED PLAY AGAIN LABEL !!!")
            StartScene.score = 0
            let playAgainTransition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
            let nextScene = StartScene(fileNamed: "StartScene")
            nextScene?.scaleMode = .aspectFill
            self.view?.presentScene(nextScene!, transition: playAgainTransition)
            self.removeAllActions()
            self.removeAllChildren()
        } else if (self.mainMenuLabel?.contains((current_touch?.location(in: self))!))! {
            print("TAPPED MAIN MENU LABEL !!!")
            StartScene.score = 0
            let mainMenuTransition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let nextScene = GameScene(fileNamed: "GameScene")
            nextScene?.scaleMode = .aspectFill
            self.view?.presentScene(nextScene!, transition: mainMenuTransition)
            self.removeAllActions()
            self.removeAllChildren()
        } else if (self.shareLabel?.contains((current_touch?.location(in: self))!))! {
            print("TAPPED SHARE LABEL !!!")
            let postText = String(format: "https://itunes.apple.com/us/app/h4rd/id1422382715?ls=1&mt=8 Check out my score in H4RD!!! Can you beat %.1f?", self.currentScore!)
            StartScene.score = 0
            let activityItems = [postText]
            let activityController = UIActivityViewController(activityItems: activityItems,
                                                              applicationActivities: nil)
        //    activityController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            let controller: UIViewController = (scene?.view!.window!.rootViewController!)!
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                let popOver: UIPopoverController = UIPopoverController(contentViewController: activityController)
                popOver.present(from: (self.shareLabel?.accessibilityFrame)!, in: self.view!,
                                permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            } else {
                controller.present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
}
