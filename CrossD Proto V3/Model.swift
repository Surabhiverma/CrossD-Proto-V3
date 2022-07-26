//
//  Model.swift
//  CrossD Proto V3
//
//  Created by Surabhi Verma on 24/07/2022.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename).sink(receiveCompletion: {
            loadCompletion in
            //Error callback
            print("DEBUG: Unable to load model entity - \(modelName)")
        }, receiveValue: {
            modelEntity in
            //sucess callback
            self.modelEntity = modelEntity
            print("DEBUG: Loaded the model entity - \(modelName)")
        })
    }
}

