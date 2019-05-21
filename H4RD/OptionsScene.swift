//
//  OptionsScene.swift
//  H4RD
//
//  Created by Bahadir Altun on 23.07.2018.
//  Copyright © 2018 Bahadir Altun. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import StoreKit

class OptionsScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    let userDefaults = UserDefaults.standard
    
    private var lastUpdateTime : TimeInterval = 0
    
    private var soundOnLabel : SKLabelNode?
    private var soundOffLabel : SKLabelNode?
    private var musicOnLabel : SKLabelNode?
    private var musicOffLabel : SKLabelNode?
    private var shareLabel : SKLabelNode?
    private var saveLabel : SKLabelNode?

    private var spinnyNode : SKShapeNode?

    var buttonSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "buttonSound", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()

    var currentSoundStatus : Bool?
    var currentMusicStatus : Bool?

    var soundStatus : Bool?
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        soundStatus = userDefaults.bool(forKey: "SOUNDSTATUS")
        
        try! audioPlayer = AVAudioPlayer(contentsOf: buttonSound as URL)
        audioPlayer.prepareToPlay()
        
        self.soundOnLabel = self.childNode(withName: "//soundOnLabel") as? SKLabelNode
        self.soundOffLabel = self.childNode(withName: "//soundOffLabel") as? SKLabelNode
        self.musicOnLabel = self.childNode(withName: "//musicOnLabel") as? SKLabelNode
        self.musicOffLabel = self.childNode(withName: "//musicOffLabel") as? SKLabelNode
        self.shareLabel = self.childNode(withName: "//shareLabel") as? SKLabelNode
        self.saveLabel = self.childNode(withName: "//saveLabel") as? SKLabelNode
        
        currentSoundStatus = userDefaults.bool(forKey: "SOUNDSTATUS")
        currentMusicStatus = userDefaults.bool(forKey: "MUSICSTATUS")
        
        soundOnLabel?.alpha = currentSoundStatus! ? 1.0 : 0.3
        soundOffLabel?.alpha = currentSoundStatus! ? 0.3 : 1.0
        
        musicOnLabel?.alpha = currentMusicStatus! ? 1.0 : 0.3
        musicOffLabel?.alpha = currentMusicStatus! ? 0.3 : 1.0

        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(ellipseOf: CGSize.init(width: w, height: w))
        self.spinnyNode?.fillColor = UIColor.init(red: 156, green: 179, blue: 229, alpha: 0.05)
        
        if let spinnyNode = self.spinnyNode {
            
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.1),
                                              SKAction.fadeOut(withDuration: 0.05),
                                              SKAction.removeFromParent()]))
        }

    }

    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            self.addChild(n)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if soundStatus! {
            audioPlayer.play()
        }
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let current_touch = touches.first
        
        if (soundOnLabel?.contains((current_touch?.location(in: self))!))!
            && currentSoundStatus == false {
            currentSoundStatus = true
        //     userDefaults.set(true, forKey: "SOUNDSTATUS")
            soundOnLabel?.alpha = 1
            soundOffLabel?.alpha = 0.3
        }
        
        else if (soundOffLabel?.contains((current_touch?.location(in: self))!))!
            && currentSoundStatus == true {
            currentSoundStatus = false
        //    userDefaults.set(false, forKey: "SOUNDSTATUS")
            soundOffLabel?.alpha = 1
            soundOnLabel?.alpha =  0.3
        }
        
        else if (musicOnLabel?.contains((current_touch?.location(in: self))!))!
            && currentMusicStatus == false {
            currentMusicStatus = true
        //    userDefaults.set(true, forKey: "MUSICSTATUS")
            musicOnLabel?.alpha = 1
            musicOffLabel?.alpha = 0.3
        }
        
        else if (musicOffLabel?.contains((current_touch?.location(in: self))!))!
            && currentMusicStatus == true {
            currentMusicStatus = false
        //    userDefaults.set(false, forKey: "MUSICSTATUS")
            musicOffLabel?.alpha = 1
            musicOnLabel?.alpha =  0.3
        }
        
        else if (shareLabel?.contains((current_touch?.location(in: self))!))! {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }

        else if (saveLabel?.contains((current_touch?.location(in: self))!))! {
            print("SAVED SUCCESFULLY !!!")
            userDefaults.set(currentSoundStatus!, forKey: "SOUNDSTATUS")
            userDefaults.set(currentMusicStatus!, forKey: "MUSICSTATUS")
            let mainMenuTransition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let nextScene = GameScene(fileNamed: "GameScene")
            nextScene?.scaleMode = .aspectFill
            self.view?.presentScene(nextScene!, transition: mainMenuTransition)
            self.removeAllActions()
            self.removeAllChildren()
        }
        
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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
