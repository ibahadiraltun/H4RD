//
//  GameViewController.swift
//  H4RD
//
//  Created by Bahadir Altun on 9.07.2018.
//  Copyright © 2018 Bahadir Altun. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import FirebaseDatabase

class GameViewController: UIViewController {

    let userDefaults = UserDefaults.standard

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var usernameLengthWarningLabel: UILabel!
    
    static var username : String?
    static var firstPlaying : Bool?

    var ref : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        GameViewController.firstPlaying = userDefaults.bool(forKey: "FIRSTPLAYING")
        GameViewController.username = userDefaults.string(forKey: "USERNAME")

        if GameViewController.firstPlaying == true {
            usernameTextField.removeFromSuperview()
            doneButton.removeFromSuperview()
            usernameLengthWarningLabel.removeFromSuperview()
        }
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = false
                    view.showsNodeCount = false
                }
            }
        }
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        let username = usernameTextField.text
        let _username = username?.trimmingCharacters(in: .whitespacesAndNewlines)
        if ((_username?.isEmpty)! == false && (_username?.count)! > 10) {
            usernameLengthWarningLabel.alpha = 1
        }
        else if _username?.isEmpty == false {
            usernameTextField.removeFromSuperview()
            doneButton.removeFromSuperview()
            usernameLengthWarningLabel.removeFromSuperview()
            GameViewController.firstPlaying = true
            GameViewController.username = _username
            userDefaults.set(true, forKey: "FIRSTPLAYING")
            userDefaults.set(_username, forKey: "USERNAME")
            ref?.child("users").child(_username!).setValue("")
            
            if let scene = GKScene(fileNamed: "GameScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
                    
                    // Copy gameplay related content over to the scene
                    sceneNode.entities = scene.entities
                    sceneNode.graphs = scene.graphs
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    if let view = self.view as! SKView? {
                        view.presentScene(sceneNode)
                        
                        view.ignoresSiblingOrder = true
                        
                        view.showsFPS = false
                        view.showsNodeCount = false
                    }
                }
            }

        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
