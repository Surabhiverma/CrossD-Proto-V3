//
//  ARViewController.swift
//  CrossD Proto V3
//
//  Created by Surabhi Verma on 24/07/2022.
//

import Foundation
import ARKit
import RealityKit

final class ARViewController: NSObject, ObservableObject, ARSessionDelegate {
    static var shared = ARViewController()
    
    @Published var arView:ARView
    private var objectAnchor: AnchorEntity?
    private var modelEntity: ModelEntity?
    
    override init() {
        arView = ARView(frame: .zero)
    }
    
    //set model Entity
    public func setModelEntityAndReconizeTap(modelEntity: ModelEntity) {
        self.modelEntity = modelEntity
        startGesturerecognizer()
    }
    
    public func startARSession() {
        //1. start plane detection, horizontal & images
         startPlaneDetection()
         
        //2. Add 2D point for gesture recognizer
         //arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    //Add 2D point for gesture reconizer
    func startGesturerecognizer() {
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {

        let tapLocation = recognizer.location(in: arView)
        
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            
            let worldPos = simd_make_float3(firstResult.worldTransform.columns.3)
            
            print("Heard tap")
            
            //load the model entity
            //let sphere = createSphere()
            
            //place object
            placeObject(object: self.modelEntity, at: worldPos)
        }
    }
    
    func startPlaneDetection()  {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Pics", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        arView.automaticallyConfigureSession = true
        
        let config = ARWorldTrackingConfiguration()
        config.detectionImages = referenceImages
        config.maximumNumberOfTrackedImages = 1
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        arView.session.delegate = self
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func createSphere() -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: 0.05)
        
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        
        let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
        
        return sphereEntity
    }
    
    func placeObject(object:ModelEntity?, at location:SIMD3<Float>) {
        
        //create anchor
        objectAnchor = AnchorEntity(world: location)
        
        //tie model to the anchor
        objectAnchor!.addChild(object!)
        
        //Add anchor to the scene
        arView.scene.addAnchor(objectAnchor!)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            print("Found Image Anchor")
    
            for anchor in anchors {
                //Image anchor
    
                if let imageAnchor = anchor as? ARImageAnchor {
    
                    print("Found Image Anchor")
                    //Place object on the image
                    let sphere = ARViewController.shared.createSphere()
    
                    let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
    
                    imageAnchorEntity.addChild(sphere)
                    //arView.session.delegate = self
                    arView.scene.addAnchor(imageAnchorEntity)
    
                }
            }
        }
    
}
