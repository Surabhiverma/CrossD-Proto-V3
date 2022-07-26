////
////  ImageDetection.swift
////  CrossD Proto V3
////
////  Created by Surabhi Verma on 24/07/2022.
////
//
//import Foundation
//import ARKit
//import RealityKit
//
//class ImageDetection: ARSessionDelegate {
//    
//    var arView : ARView
//    
//    init()
//    {
//        self.arView = ARViewController.shared.arView
//    }
//
//
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        print("Found Image Anchor")
//
//        for anchor in anchors {
//            //Image anchor
//
//            if let imageAnchor = anchor as? ARImageAnchor {
//
//                print("Found Image Anchor")
//                //Place object on the image
//                let sphere = ARViewController.shared.createSphere()
//
//                let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
//
//                imageAnchorEntity.addChild(sphere)
//                //arView.session.delegate = self
//                arView.scene.addAnchor(imageAnchorEntity)
//
//            }
//        }
//    }
//}
