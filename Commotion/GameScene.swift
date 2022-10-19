//
//  GameScene.swift
//  Commotion
//
//  Created by zhongyuan liu on 10/19/22.
//  Copyright © 2022 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate{

    //@IBOutlet weak var scoreLabel: UILabel!
       
       // MARK: Raw Motion Functions
       let motion = CMMotionManager()
       func startMotionUpdates(){
           // if motion is available, start updating the device motion
           if self.motion.isDeviceMotionAvailable{
               self.motion.deviceMotionUpdateInterval = 0.2
               self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
           }
       }
       
       func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
           // make gravity in the game als the simulator gravity
           if let gravity = motionData?.gravity {
               // cannot move a pinned block?
               let action = SKAction.moveBy(x: gravity.x*5, y: 0, duration: 0.1)
               self.paddle.run(action, withKey: "temp")
               self.physicsWorld.gravity = CGVector(dx: CGFloat(0), dy: CGFloat(0))
           }
       }
       
       
       // MARK: View Hierarchy Functions
       // this is like out "View Did Load" function
       override func didMove(to view: SKView) {
           physicsWorld.contactDelegate = self
           backgroundColor = SKColor.cyan
           
           // start motion for gravity
           self.startMotionUpdates()
           
           // make sides to the screen
           self.addSidesAndTop()
           
           // add some stationary blocks on left and right
           self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.1, y: size.height * 0.25))
           self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.9, y: size.height * 0.25))
           
           let blockWidth = size.width * 0.1
           //add static blocks across top
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth, y: size.height*0.9))
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth*2, y: size.height*0.9))
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth*3, y: size.height*0.9))
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth*4, y: size.height*0.9))
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth*5, y: size.height*0.9))
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth*6, y: size.height*0.9))
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth*7, y: size.height*0.9))
           self.addStaticBlockAtPoint(CGPoint(x: blockWidth*8, y: size.height*0.9))
           
           // add a spinning block
           self.addBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.05))
           
           // add in the interaction sprite
           self.addSpriteBottle()
           
           // add a scorer
           self.addScore()
           
           // update a special watched property for score
           self.score = 0
       }
       
       // MARK: Create Sprites Functions
       let paddle = SKSpriteNode()
       let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
       var score:Int = 0 {
           willSet(newValue){
               DispatchQueue.main.async{
                   self.scoreLabel.text = "Score: \(newValue)"
               }
           }
       }
       
       func addScore(){
           
           scoreLabel.text = "Score: 0"
           
           scoreLabel.fontSize = 20
           scoreLabel.fontColor = SKColor.yellow
           scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
           
           addChild(scoreLabel)
       }
       
       
       func addSpriteBottle(){
           let spriteA = SKSpriteNode(imageNamed: "ball") // this is literally a sprite bottle... 😎
           
           spriteA.size = CGSize(width:size.width*0.1,height:size.width * 0.1)
           
           _ = random(min: CGFloat(0.1), max: CGFloat(0.9))
           spriteA.position = CGPoint(x: paddle.position.x, y: paddle.position.y+size.height*0.1)
           
           spriteA.physicsBody = SKPhysicsBody(circleOfRadius: size.width*0.05)
           spriteA.physicsBody?.restitution = 1
           spriteA.physicsBody?.isDynamic = true
           // for collision detection we need to setup these masks
           spriteA.physicsBody?.contactTestBitMask = 0x00000001
           spriteA.physicsBody?.collisionBitMask = 0x00000001
           spriteA.physicsBody?.categoryBitMask = 0x00000001
           spriteA.physicsBody?.velocity = CGVector(dx: 10, dy: 400)
           self.addChild(spriteA)
       }
       
       func addBlockAtPoint(_ point:CGPoint){
           
           paddle.color = UIColor.orange
           paddle.size = CGSize(width:size.width*0.3,height:size.height * 0.01)
           paddle.position = point
           
           paddle.physicsBody = SKPhysicsBody(rectangleOf:paddle.size)
           paddle.physicsBody?.restitution=1.1
           paddle.physicsBody?.contactTestBitMask = 0x00000001
           paddle.physicsBody?.collisionBitMask = 0x00000001
           paddle.physicsBody?.categoryBitMask = 0x00000001
           paddle.physicsBody?.isDynamic = true
           paddle.physicsBody?.pinned = false
           paddle.physicsBody?.affectedByGravity = false
           paddle.physicsBody?.mass = 100000
           
           self.addChild(paddle)

       }
       
       func addStaticBlockAtPoint(_ point:CGPoint){
           let 🔲 = SKSpriteNode()
           
           🔲.color = UIColor.yellow
           🔲.size = CGSize(width:size.width*0.1,height:size.height * 0.05)
           🔲.position = point
           🔲.physicsBody = SKPhysicsBody(rectangleOf:🔲.size)
           🔲.physicsBody?.restitution=1
           🔲.physicsBody?.isDynamic = true
           🔲.physicsBody?.pinned = true
           🔲.physicsBody?.allowsRotation = true
           🔲.name="hitBlock"
           self.addChild(🔲)
           
       }
       
       func addSidesAndTop(){
           let left = SKSpriteNode()
           let right = SKSpriteNode()
           let top = SKSpriteNode()
           
           left.size = CGSize(width:size.width*0.1,height:size.height)
           left.position = CGPoint(x:0, y:size.height*0.5)
           
           right.size = CGSize(width:size.width*0.1,height:size.height)
           right.position = CGPoint(x:size.width, y:size.height*0.5)
           
           top.size = CGSize(width:size.width,height:size.height*0.1)
           top.position = CGPoint(x:size.width*0.5, y:size.height)
           
           for obj in [left,right,top]{
               obj.color = UIColor.yellow
               obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
               obj.physicsBody?.isDynamic = true
               obj.physicsBody?.pinned = true
               obj.physicsBody?.allowsRotation = false
               obj.physicsBody?.restitution=1
               self.addChild(obj)
           }
       }
       
       // MARK: =====Delegate Functions=====
       override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.addSpriteBottle()
       }
       
       // here is our collision function
       func didBegin(_ contact: SKPhysicsContact) {
           // if anything interacts with the spin Block, then we should update the score
           if contact.bodyA.node == paddle || contact.bodyB.node == paddle {
               self.score += 1
           }
           if contact.bodyA.node?.name == "hitBlock" || contact.bodyB.node?.name == "hitBlock" {
               contact.bodyA.node?.removeFromParent()
               
           }
           // TODO: How might we add additional scoring mechanisms?
       }
       
       // MARK: Utility Functions (thanks ray wenderlich!)
       // generate some random numbers for cor graphics floats
       func random() -> CGFloat {
           return CGFloat(Float(arc4random()) / Float(Int.max))
       }
       
       func random(min: CGFloat, max: CGFloat) -> CGFloat {
           return random() * (max - min) + min
       }
}
