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
}
