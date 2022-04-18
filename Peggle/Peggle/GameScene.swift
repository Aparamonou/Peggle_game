//
//  GameScene.swift
//  Peggle
//
//  Created by Alex Paramonov on 30.03.22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
     
     
     var scoreLabel: SKLabelNode!
     var editLabel: SKLabelNode!
     var moveLabel: SKLabelNode!
     
    
     var ballColour = ["ballRed","ballYellow", "ballGreen", "ballCyan", "ballPurple", "ballBlue", "ballGrey" ]
     
     
     
     var scoreMove = 5 {
          didSet {
               moveLabel.text = "Moves left - \(scoreMove)"
          }
     }
     var edittingMode: Bool = false  {
          didSet {
               if edittingMode {
                    editLabel.text = "Done"
               } else {
                    editLabel.text = "Edit"
               }
          }
     }
     
     var score = 0 {
          didSet {
               scoreLabel.text = "Score - \(score)"
          }
     }
     
     
     override func didMove(to view: SKView) {
          // загрузаем наш фон
          let background = SKSpriteNode(imageNamed: "background.jpg")
          background.position = CGPoint(x: 512, y: 384)
          background.blendMode = .replace
          background.zPosition = -1
          addChild(background)
          physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
          
          makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
          makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
          makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
          makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
          
          makeBouncer(at: CGPoint(x: 0, y: 0))
          makeBouncer(at: CGPoint(x: 256, y: 0))
          makeBouncer(at: CGPoint(x: 512, y: 0))
          makeBouncer(at: CGPoint(x: 768, y: 0))
          makeBouncer(at: CGPoint(x: 1024, y: 0))
          
          physicsWorld.contactDelegate = self
          
          setLabels()
     }
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          
          if let touch = touches.first {
               let location = touch.location(in: self)
               
               let object = nodes(at: location)
               if object.contains(editLabel){
                    edittingMode.toggle()
               } else {
                    if edittingMode {
                         let size = CGSize(width: Int.random(in: 16...128), height: 16)
                         let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                         box.zRotation = CGFloat.random(in: 0...3)
                         box.position = location
                         box.name = "box"
                         box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                         box.physicsBody?.isDynamic = false
                         
                         addChild(box	)
                    } else {
                         if scoreMove <= 0 {
                              
                         } else {
                              let ball = SKSpriteNode(imageNamed: ballColour.randomElement() ?? "ballCyan")
                              ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                              ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                              ball.physicsBody?.restitution = 0.4
                              ball.position = CGPoint(x: location.x, y: 700)
                              ball.name  = "ball"
                              addChild(ball)
                              scoreMove -= 1
                         }
                         
                    }
               }
          }
     }
     
     func didBegin(_ contact: SKPhysicsContact) {
          guard let nodeA = contact.bodyA.node else {return}
          guard let nodeB = contact.bodyB.node else {return}
          
          
          if nodeA.name == "ball" {
               collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
          } else if  nodeB.name == "ball" {
               collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
          }
          
          
     }
     
     private  func setLabels() {
          scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
          scoreLabel.text = "Score - 0"
          scoreLabel.horizontalAlignmentMode = .center
          scoreLabel.position = CGPoint(x: 880, y: 700)
          addChild(scoreLabel)
          
          editLabel = SKLabelNode(fontNamed: "Chalkduster")
          editLabel.text = "Edit"
          editLabel.position = CGPoint(x: 80, y: 700)
          addChild(editLabel)
          
          
          moveLabel = SKLabelNode(fontNamed: "Chalkduster")
          moveLabel.text = "Moves left - 5"
          moveLabel.position = CGPoint(x: 500, y: 700)
          addChild(moveLabel)
     }
     
     func makeBouncer(at position: CGPoint){
          let bouncer = SKSpriteNode(imageNamed: "bouncer")
          bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0 )
          bouncer.position = position
          bouncer.physicsBody?.isDynamic = false
          addChild(bouncer)
     }
     
     func makeSlot(at position: CGPoint, isGood: Bool) {
          var slotBase: SKSpriteNode
          var slotGlow: SKSpriteNode
          
          if isGood {
               slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
               slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
               slotBase.name = "good"
          } else {
               slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
               slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
               slotBase.name = "bad"
          }
          
          slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
          slotBase.physicsBody?.isDynamic = false
          
          slotBase.position = position
          slotGlow.position = position
          addChild(slotBase)
          addChild(slotGlow)
          
          let spin = SKAction.rotate(byAngle: .pi, duration: 10)
          let spinForever = SKAction.repeatForever(spin)
          slotGlow.run(spinForever)
     }
     
     func collisionBetween(ball: SKNode, object: SKNode) {
          if object.name == "good" {
               destroy(ball: ball)
               score += 1
               scoreMove += 1
          } else if object.name == "bad" {
               destroy(ball: ball)
               score -= 1
          }
          
          if object.name ==  "box" {
               destroy(ball: object)
          }
     }
     
     func destroy(ball: SKNode) {
          if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
               fireParticles.position = ball.position
               addChild(fireParticles)
          }
          ball.removeFromParent()
          
          
     }
     
     
     
     
}
