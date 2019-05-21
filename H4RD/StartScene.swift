//
//  StartScene.swift
//  H4RD
//
//  Created by Bahadir Altun on 9.07.2018.
//  Copyright © 2018 Bahadir Altun. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class StartScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    let userDefaults = UserDefaults.standard
    
    private var lastUpdateTime : TimeInterval = 0
    
    private var scoreLabel : SKLabelNode?
    private var initialLabel : SKLabelNode?
    
    private var finger : SKShapeNode?
    private var finger_last : SKShapeNode?
    private var enemy : SKShapeNode?
    
    private var finger1 : SKShapeNode?
    private var finger2 : SKShapeNode?
    private var finger3 : SKShapeNode?
    private var finger4 : SKShapeNode?
    
    private var scoreTimer : Timer?
    private var enemyTimer : Timer?
    
    static var score : Double = 0
    
    private var fingers_count : Int = 0
    private var didBeginContact : Bool = false
    
    let fingerCategory : UInt32 = 0x1 << 0
    let enemyCategory : UInt32 = 0x1 << 1
    
    var fingerSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "fingerSound", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()

    var collisionSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "collisionSound2", ofType: "mp3")!)
    var audioPlayerCollision = AVAudioPlayer()

    var soundtrack = NSURL(fileURLWithPath: Bundle.main.path(forResource: "H4RD-Soundtrack", ofType: "mp3")!)
    var audioPlayerSoundtrack = AVAudioPlayer()
    
    var musicStatus : Bool?
    var soundStatus : Bool?
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        musicStatus = userDefaults.bool(forKey: "MUSICSTATUS")
        soundStatus = userDefaults.bool(forKey: "SOUNDSTATUS")
        
        try! audioPlayer = AVAudioPlayer(contentsOf: fingerSound as URL)
        audioPlayer.prepareToPlay()
        
        try! audioPlayerCollision = AVAudioPlayer(contentsOf: collisionSound as URL)
        audioPlayerCollision.prepareToPlay()
        audioPlayerCollision.volume = 7.5

        try! audioPlayerSoundtrack = AVAudioPlayer(contentsOf: soundtrack as URL)
        audioPlayerSoundtrack.prepareToPlay()
        audioPlayerSoundtrack.numberOfLoops = -1
        
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        
        let w = (self.size.width + self.size.height) * 0.05
        self.finger = SKShapeNode.init(ellipseOf: CGSize.init(width: w, height: w))
        self.finger?.fillColor = UIColor.init(red: 22, green: 20, blue: 70, alpha: 0.05)

        if let finger = self.finger {
            finger.run(SKAction.sequence([SKAction.wait(forDuration: 0.09),
                                              SKAction.fadeOut(withDuration: 0.06),
                                              SKAction.removeFromParent()]))
        }
        
        self.finger_last = SKShapeNode.init(ellipseOf: CGSize.init(width: w, height: w))
        self.finger_last?.fillColor = UIColor.init(red: 22, green: 20, blue: 70, alpha: 0.05)
        if let finger_last = self.finger_last {
            finger_last.physicsBody = SKPhysicsBody(circleOfRadius: w / 2)
            finger_last.physicsBody?.affectedByGravity = false
            finger_last.physicsBody?.categoryBitMask = fingerCategory
            finger_last.physicsBody?.contactTestBitMask = enemyCategory
            finger_last.physicsBody?.collisionBitMask = 0
        }

        self.enemy = SKShapeNode.init(ellipseOf: CGSize.init(width: w / 2, height: w / 2))
        self.enemy?.fillColor = UIColor.init(red: 70, green: 20, blue: 20, alpha: 0.05)
        if let enemy = self.enemy {
            enemy.physicsBody = SKPhysicsBody(circleOfRadius: w / 4)
            enemy.physicsBody?.categoryBitMask = enemyCategory
            enemy.physicsBody?.contactTestBitMask = fingerCategory
            enemy.run(SKAction.sequence([SKAction.wait(forDuration: 5.0),
                                            SKAction.removeFromParent()]))
        }
        
        self.isUserInteractionEnabled = true
        
        perform(#selector(showInitialLabel), with: nil, afterDelay: 0.7)
        
    }
    
    @objc func showInitialLabel() {
        self.initialLabel = self.childNode(withName: "//initialLabel") as? SKLabelNode
        self.initialLabel?.alpha = 1
    }
    
    func createFinger1(atPos pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger1 = self.finger_last?.copy() as! SKShapeNode?
            finger1?.position = pos
            self.addChild(n)
            self.addChild(finger1!)
        }
    }
    
    func finger1Moved(toPoint pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger1?.position = pos
            self.addChild(n)
        }
    }
    
    func createFinger2(atPos pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger2 = self.finger_last?.copy() as! SKShapeNode?
            finger2?.position = pos
            self.addChild(n)
            self.addChild(finger2!)
        }
    }
    
    func finger2Moved(toPoint pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger2?.position = pos
            self.addChild(n)
        }
    }

    func createFinger3(atPos pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger3 = self.finger_last?.copy() as! SKShapeNode?
            finger3?.position = pos
            self.addChild(n)
            self.addChild(finger3!)
        }
    }
    
    func finger3Moved(toPoint pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger3?.position = pos
            self.addChild(n)
        }
    }
    
    func createFinger4(atPos pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger4 = self.finger_last?.copy() as! SKShapeNode?
            finger4?.position = pos
            self.addChild(n)
            self.addChild(finger4!)
        }
    }
    
    func finger4Moved(toPoint pos: CGPoint) {
        if let n = self.finger?.copy() as! SKShapeNode? {
            n.position = pos
            finger4?.position = pos
            self.addChild(n)
        }
    }
    
    @objc func startScoring() {
        StartScene.score = StartScene.score + 0.1
        self.scoreLabel?.text = String(format: "%.1f", StartScene.score)
        scoreTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                                          selector: #selector(startScoring), userInfo: nil, repeats: false)
    }
    
    @objc func playSoundtrack() {
        audioPlayerSoundtrack.play()
    }
    
    @objc func deployEnemies() {
        if let current_enemy = self.enemy?.copy() as! SKShapeNode? {
            let randomX = randomInt(min: Int(-(self.view?.frame.width)! - 100),
                                    max: Int(+((self.view?.frame.width)! + 100)))
            current_enemy.position = CGPoint(x: randomX, y: Int((self.view?.frame.height)!) + 500)
            self.addChild(current_enemy)
            enemyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(deployEnemies), userInfo: nil, repeats: false)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("CONTACT")
        if (contact.bodyA.categoryBitMask == fingerCategory)
            && (contact.bodyB.categoryBitMask == enemyCategory)
            && (didBeginContact == false) {
            didBeginContact = true
            if musicStatus! {
                audioPlayerCollision.play()
            }
            print("COLLISION !!!")
            scoreTimer?.invalidate()
            let path: String = Bundle.main.path(forResource: "collision", ofType: "sks")!
            let collision = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            collision.position = contact.contactPoint
            collision.particleSize = CGSize(width: (self.view?.frame.width)! * 2, height: (self.view?.frame.height)! * 2)
            self.addChild(collision)
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            finger1?.physicsBody?.categoryBitMask = 0
            finger2?.physicsBody?.categoryBitMask = 0
            finger3?.physicsBody?.categoryBitMask = 0
            finger4?.physicsBody?.categoryBitMask = 0
            perform(#selector(gameOver), with: nil, afterDelay: 0.7)
        }
        
    }
 
    @objc func gameOver() {
        let gameOverTransition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
        let nextScene = GameOverScene(fileNamed: "GameOverScene")
        nextScene?.scaleMode = .aspectFill
        self.view?.presentScene(nextScene!, transition: gameOverTransition)
        self.removeAll()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if didBeginContact {
            return
        }
        for t in touches {
            fingers_count = fingers_count + 1
            if fingers_count <= 4 {
                if soundStatus! {
                    audioPlayer.play()
                }
                if fingers_count == 1 {
                    self.createFinger1(atPos: t.location(in: self))
                    self.initialLabel?.text = "3 More Fingers"
                } else if fingers_count == 2 {
                    self.createFinger2(atPos: t.location(in: self))
                    self.initialLabel?.text = "2 More :("
                } else if fingers_count == 3 {
                    self.createFinger3(atPos: t.location(in: self))
                    self.initialLabel?.text = "LAST ONE !!!"
                } else {
                    self.createFinger4(atPos: t.location(in: self))
                    self.initialLabel?.text = "RUNNN !!!"
                    self.initialLabel?.run(SKAction.fadeOut(withDuration: 1.5))
                    perform(#selector(deployEnemies), with: self, afterDelay: 1.0)
                    perform(#selector(startScoring), with: self, afterDelay: 1.0)
                    if musicStatus! {
                        perform(#selector(playSoundtrack), with: self, afterDelay: 1.0)
                    }
                }
            } else {
                let distance1 = self.getDistance(point1: t.location(in: self), point2: (finger1?.position)!)
                let distance2 = self.getDistance(point1: t.location(in: self), point2: (finger2?.position)!)
                let distance3 = self.getDistance(point1: t.location(in: self), point2: (finger3?.position)!)
                let distance4 = self.getDistance(point1: t.location(in: self), point2: (finger4?.position)!)
                let mn = min(distance1, min(distance2, min(distance3, distance4)))
                if mn == distance1 { finger1Moved(toPoint: t.location(in: self)) }
                else if mn == distance2 { finger2Moved(toPoint: t.location(in: self)) }
                else if mn == distance3 { finger3Moved(toPoint: t.location(in: self)) }
                else { finger4Moved(toPoint: t.location(in: self)) }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if didBeginContact {
            return
        }
        if fingers_count >= 4 {
            for t in touches {
                if (finger1?.contains(t.location(in: self)))! {
                    print("HOOORAYY 111 !!!")
                    self.finger1Moved(toPoint: t.location(in: self))
                }
                else if (finger2?.contains(t.location(in: self)))! {
                    print("HOOORAYY 222 !!!")
                    self.finger2Moved(toPoint: t.location(in: self))
                }
                else if (finger3?.contains(t.location(in: self)))! {
                    print("HOOORAYY 333 !!!")
                    self.finger3Moved(toPoint: t.location(in: self))
                }
                else if (finger4?.contains(t.location(in: self)))! {
                    print("HOOORAYY 444 !!!")
                    self.finger4Moved(toPoint: t.location(in: self))
                }
                else {
                    let distance1 = self.getDistance(point1: t.location(in: self), point2: (finger1?.position)!)
                    let distance2 = self.getDistance(point1: t.location(in: self), point2: (finger2?.position)!)
                    let distance3 = self.getDistance(point1: t.location(in: self), point2: (finger3?.position)!)
                    let distance4 = self.getDistance(point1: t.location(in: self), point2: (finger4?.position)!)
                    let mn = min(distance1, min(distance2, min(distance3, distance4)))
                    if mn == distance1 { finger1Moved(toPoint: t.location(in: self)) }
                    else if mn == distance2 { finger2Moved(toPoint: t.location(in: self)) }
                    else if mn == distance3 { finger3Moved(toPoint: t.location(in: self)) }
                    else { finger4Moved(toPoint: t.location(in: self)) }
                }
            }
        }
    }
    
    func removeAll() {
        // remove all nodes in current scene
        enemyTimer?.invalidate()
        self.removeAllActions()
        self.removeAllChildren()
    }
    
    func getDistance(point1 pos1: CGPoint, point2 pos2: CGPoint) -> Int {
        let xx = (pos1.x - pos2.x) * (pos1.x - pos2.x)
        let yy = (pos1.y - pos2.y) * (pos1.y - pos2.y)
        return Int(xx + yy)
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)));
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity.dy = -3.0
        physicsWorld.contactDelegate = self
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
