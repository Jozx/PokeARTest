//
//  Scene.swift
//  PokeARTest
//
//  Created by Jose Saracho on 8/25/18.
//  Copyright © 2018 JosApp. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    let remainingLabel = SKLabelNode()
    var timer : Timer?
    var targetCreated = 0
    var targetCount = 0 {
        didSet{
            self.remainingLabel.text = "Faltan \(targetCount)"
        }
    }
    let startTime = Date()
    
    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        
        //Configuracion HUD
        remainingLabel.fontSize = 30
        remainingLabel.fontName = "Avenir Next"
        remainingLabel.fontColor = .white
        
        remainingLabel.position = CGPoint(x:0, y:view.frame.midY - 50)
        addChild(remainingLabel)
        
        targetCount = 0
        
        //Creacion de enemigos cada 3 segundos
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (timer) in
            self.createTarget()
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //localizar el primer toque del conjunto de toques
        //mirar si el toque cae dentro de la vista del AR
        guard let touch = touches.first else {return}
        
        let location = touch.location(in: self)
        
        print("El toque ha sido en:  \(location.x), \(location.y)")
        
        //buscar todos los nodos que han sido tocados por ese toque de usuario
        let hit = nodes(at: location)
        
        //agarrar el primer Sprite del array que devuelve el metodo anterior (si lo hay) y se anima el objeto hasta desaparecer
        if let sprite = hit.first {
            let scaleOut = SKAction.scale(to: 2, duration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            
            //en grupo realiza las acciones al mismo tiempo
            let groupAction = SKAction.group([scaleOut, fadeOut, deathSound])
            //en secuencia, lo hace una a la vez
            let sequenceAction = SKAction.sequence([groupAction, SKAction.removeFromParent()])
            
            sprite.run(sequenceAction)
            
        //actualizar que hay un objeto menos con la variable targetCount
            
            targetCount -= 1
            
            if targetCreated == 25 && targetCount == 0 {
                gameOver()
            }
            
        }
    
    }
    
    func createTarget() {
        if targetCreated == 25 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetCreated += 1
        targetCount += 1
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        /* Pos (0,0,0) Rot = 0
          0  1  2  3
         [1, 0, 0, 0] -> x
         [0, 1, 0, 0] -> y
         [0, 0, 1, 0] -> z
         [0, 0, 0, 1] -> t
         */
        //Generador numero aleatorio
        let random = GKRandomSource.sharedRandom()
        
        //Matriz de rotacion en X
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 1, 0, 0))
        
        //Matriz de rotacion en Y
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 0, 1, 0))
       
        //Combinar las dos rotaciones con un producto de matrices
        let rotation = simd_mul(rotateX, rotateY)
        
        //Crear translacion de 1.5 metros en la direccion de la pantalla
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        //Combinar la rotacion del paso 4 con la translacion del paso 5
        let finalTransform = simd_mul(rotation, translation)
        
        //Crear un punto de ancla
        let anchor = ARAnchor(transform: finalTransform)
        
        //Añadir esa ancla a la escena
        sceneView.session.add(anchor: anchor)
    }
    
    func gameOver() {
        //ocultar remainingLabel
        remainingLabel.removeFromParent()
        
        //crear una nueva imagen con la foto de game over
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        addChild(gameOver)
        
        //calcular el tiempo que duro la caza de objetos
        let timeTaken = Date().timeIntervalSince(startTime)
        
        //mostrar el tiempo que le ha llevado en pantalla en una etiqueta nueva
        let timeTakenLabel = SKLabelNode(text: "Te ha llevado: \(Int(timeTaken)) segundos")
        timeTakenLabel.fontSize = 40
        timeTakenLabel.color = .white
        timeTakenLabel.position = CGPoint(x: 0,//view!.frame.maxX - 50,
                                          y: -view!.frame.midY + 50)
        addChild(timeTakenLabel)
    }
}
