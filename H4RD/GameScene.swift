//
//  GameScene.swift
//  H4RD
//
//  Created by Bahadir Altun on 9.07.2018.
//  Copyright © 2018 Bahadir Altun. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    let userDefaults = UserDefaults.standard
    
    private var lastUpdateTime : TimeInterval = 0
    private var startLabel : SKLabelNode?
    private var optionsLabel : SKLabelNode?
    private var statsLabel : SKLabelNode?
    private var statsLabelNote : SKLabelNode?
    
    private var spinnyNode : SKShapeNode?
    
    var buttonSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "buttonSound", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    
    var soundStatus : Bool?
    var firstPlaying : Bool?
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        //  startLabel configuration
        self.startLabel = self.childNode(withName: "//startLabel") as? SKLabelNode
        
        //  optionsLabel configuration
        self.optionsLabel = self.childNode(withName: "//optionsLabel") as? SKLabelNode
        
        // statsLabel configuration
        self.statsLabel = self.childNode(withName: "//statsLabel") as? SKLabelNode
        self.statsLabelNote = self.childNode(withName: "//statsLabelNote") as? SKLabelNode
        
        soundStatus = userDefaults.bool(forKey: "SOUNDSTATUS")
        try! audioPlayer = AVAudioPlayer(contentsOf: buttonSound as URL)
        audioPlayer.prepareToPlay()
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(ellipseOf: CGSize.init(width: w, height: w))
        self.spinnyNode?.fillColor = UIColor.init(red: 156, green: 179, blue: 229, alpha: 0.05)
        
        if let spinnyNode = self.spinnyNode {
            
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.1),
                                              SKAction.fadeOut(withDuration: 0.05),
                                              SKAction.removeFromParent()]))
        }
        
        if GameViewController.firstPlaying! == false {
            print("FIRST PLAYYYYY")
            firstPlaying = false
            userDefaults.set(true, forKey: "SOUNDSTATUS")
            userDefaults.set(true, forKey: "MUSICSTATUS")
        } else {
            firstPlaying = true
            startLabel?.alpha = 1
            optionsLabel?.alpha = 1
            statsLabel?.alpha = 1
        }
        
        soundStatus = userDefaults.bool(forKey: "SOUNDSTATUS")
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
        if firstPlaying! == false {
            self.view?.endEditing(true)
        }
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let current_touch = touches.first
        if firstPlaying! {
            if (startLabel?.contains(current_touch!.location(in: self)))! {
            //    audioPlayer.play()
                print("TAPPED START LABEL !!!")
                userDefaults.set(false, forKey: "ISDATABASECHANGED")
                userDefaults.set(0, forKey: "CURRENTSTATSCOUNTER")
                let startTransition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                let nextScene = StartScene(fileNamed: "StartScene")
                nextScene?.scaleMode = .aspectFill
                self.view?.presentScene(nextScene!, transition: startTransition)
                self.removeAllChildren()
                self.removeAllActions()
            }
            else if (optionsLabel?.contains(current_touch!.location(in: self)))! {
            //    audioPlayer.play()
                print("TAPPED OPTIONS LABEL")
                let optionsTransition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                let nextScene = OptionsScene(fileNamed: "OptionsScene")
                nextScene?.scaleMode = .aspectFill
                self.view?.presentScene(nextScene!, transition: optionsTransition)
                self.removeAllChildren()
                self.removeAllActions()
            }
            else if (statsLabel?.contains(current_touch!.location(in: self)))! {
                print("TAPPED STATS LABEL")
            /*  statsLabelNote?.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.6),
                                                  SKAction.wait(forDuration: 1.2),
                                                  SKAction.fadeOut(withDuration: 0.6)]))  */
                
                let statsTransition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                let nextScene = StatsScene(fileNamed: "StatsScene")
                nextScene?.scaleMode = .aspectFill
                self.view?.presentScene(nextScene!, transition: statsTransition)
                self.removeAllChildren()
                self.removeAllActions()
            }
        }
        
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)));
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
