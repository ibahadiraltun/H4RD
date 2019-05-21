//
//  StatsScene.swift
//  H4RD
//
//  Created by Bahadir Altun on 18.08.2018.
//  Copyright © 2018 Bahadir Altun. All rights reserved.
//

import SpriteKit
import GameplayKit
import FirebaseDatabase
import AVFoundation

class StatsScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    let userDefaults = UserDefaults.standard
    
    private var lastUpdateTime : TimeInterval = 0
    
    private var userNameLabel : SKLabelNode?
    private var highScoreLabel : SKLabelNode?
    private var averageScoreLabel : SKLabelNode?
    private var numberOfGamesLabel : SKLabelNode?
    private var doneLabel : SKLabelNode?
    private var statusLabel : SKLabelNode?
    
    private var spinnyNode : SKShapeNode?
    
    var ref : DatabaseReference?
    var highScore : Double = 0.0
    var averageScore : Double = 0.0
    var numberOfGames : Int = 0
    var highScoreRank :Int = 1
    var averageScoreRank : Int = 1
    var numberOfGamesRank : Int = 1
    
    var buttonSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "buttonSound", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    
    var soundStatus : Bool?
    var currentStatsCounter : Int = 0
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        soundStatus = userDefaults.bool(forKey: "SOUNDSTATUS")
        try! audioPlayer = AVAudioPlayer(contentsOf: buttonSound as URL)
        audioPlayer.prepareToPlay()
        
        highScore = userDefaults.double(forKey: "HIGHSCORE")
        averageScore = userDefaults.double(forKey: "AVERAGESCORE")
        numberOfGames = userDefaults.integer(forKey: "NUMBEROFGAMES")
        
        ref = Database.database().reference()

        userNameLabel = self.childNode(withName: "//userNameLabel") as? SKLabelNode
        highScoreLabel = self.childNode(withName: "//highScoreLabel") as? SKLabelNode
        averageScoreLabel = self.childNode(withName: "//averageScoreLabel") as? SKLabelNode
        numberOfGamesLabel = self.childNode(withName: "//numberOfGamesLabel") as? SKLabelNode
        statusLabel = self.childNode(withName: "//statusLabel") as? SKLabelNode
        doneLabel = self.childNode(withName: "//doneLabel") as? SKLabelNode
        
        if (GameViewController.username != nil) {
            userNameLabel?.text = GameViewController.username

            if numberOfGames == 0 {

                highScoreLabel?.text = "N/A"
                averageScoreLabel?.text = "N/A"
                numberOfGamesLabel?.text = "N/A"

            } else {
                
                let connectedRef = Database.database().reference(withPath: ".info/connected")
                connectedRef.observe(.value, with: { snapshot in
                    if snapshot.value as? Bool ?? false {
                        print("Connected")
                        self.statusLabel?.text = "Status: Online"
                        self.currentStatsCounter = self.userDefaults.integer(forKey: "CURRENTSTATSCOUNTER")
                        if self.userDefaults.bool(forKey: "ISDATABASECHANGED") == false
                            || (self.currentStatsCounter < 2) {
                            
                            self.ref?.child("users").observe(.childAdded, with: { (snapshot) in
                            
                                if snapshot.hasChild("highScore") {
                                    let highScoreSS = snapshot.childSnapshot(forPath: "highScore")
                                    if highScoreSS.value as! Double > self.highScore {
                                        self.highScoreRank += 1
                                    }
                                }
                                
                                if snapshot.hasChild("averageScore") {
                                    let averageScoreSS = snapshot.childSnapshot(forPath: "averageScore")
                                    if averageScoreSS.value as! Double > self.averageScore {
                                        self.averageScoreRank += 1
                                    }
                                }
                                
                                if snapshot.hasChild("numberOfGames") {
                                    let numberOfGamesSS = snapshot.childSnapshot(forPath: "numberOfGames")
                                    if numberOfGamesSS.value as! Int > self.numberOfGames {
                                        self.numberOfGamesRank += 1
                                    }
                                }
                            })
                        }
                        
                        self.perform(#selector(self.setStats), with: nil, afterDelay: 1)

                    } else {
                        print("Not connected")
                        self.statusLabel?.text = "Status: Offline"
                    }
                })
                
            }
        }
 
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
    
    @objc func setStats() {
        
        currentStatsCounter = userDefaults.integer(forKey: "CURRENTSTATSCOUNTER")
        if userDefaults.bool(forKey: "ISDATABASECHANGED") == false
            || (currentStatsCounter < 2) {
            
            ref?.child("users").child(GameViewController.username!).child("highScore")
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    self.highScoreLabel?.text = String(format: "%.1f (#%d)",
                                                       snapshot.value as! Double, self.highScoreRank)
                    self.userDefaults.set(String(format: "%.1f (#%d)",
                                        snapshot.value as! Double, self.highScoreRank),
                                        forKey: "CURRENTHIGHSCORE")
                })
            
            ref?.child("users").child(GameViewController.username!).child("averageScore")
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    self.averageScoreLabel?.text = String(format: "%.1f (#%d)",
                                                          snapshot.value as! Double, self.averageScoreRank)
                    self.userDefaults.set(String(format: "%.1f (#%d)",
                                        snapshot.value as! Double, self.averageScoreRank),
                                        forKey: "CURRENTAVERAGESCORE")
                })
            
            ref?.child("users").child(GameViewController.username!).child("numberOfGames")
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    self.numberOfGamesLabel?.text = String(format: "%d (#%d)",
                                                           snapshot.value as! Int, self.numberOfGamesRank)
                    self.userDefaults.set(String(format: "%d (#%d)",
                                        snapshot.value as! Int, self.numberOfGamesRank),
                                        forKey: "CURRENTNUMBEROFGAMES")
                })
            
            userDefaults.set(true, forKey: "ISDATABASECHANGED")
            userDefaults.set(currentStatsCounter + 1, forKey: "CURRENTSTATSCOUNTER")
            
        } else {

            print("FUCK YOUR DATABASE!!!", currentStatsCounter, userDefaults.bool(forKey: "ISDATABASECHANGED"))
            self.highScoreLabel?.text = userDefaults.string(forKey: "CURRENTHIGHSCORE")
            self.averageScoreLabel?.text = userDefaults.string(forKey: "CURRENTAVERAGESCORE")
            self.numberOfGamesLabel?.text = userDefaults.string(forKey: "CURRENTNUMBEROFGAMES")
            
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
        if (doneLabel?.contains((current_touch?.location(in: self))!))! {
            let closeTransition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let nextScene = GameScene(fileNamed: "GameScene")
            nextScene?.scaleMode = .aspectFill
            self.view?.presentScene(nextScene!, transition: closeTransition)
            self.removeAllChildren()
            self.removeAllActions()

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
