//
//  ContentView.swift
//  CrossD Proto V3
//
//  Created by Surabhi Verma on 24/07/2022.
//

import SwiftUI
import ARKit
import RealityKit
import AVKit

struct ContentView: View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    //MARK: Screen recording variable
    @State var isRecording: Bool = false
    @State var url: URL?
    @State var showVideo: Bool = false
    @State var showVideoPlay: Bool = false
    
    private var models: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let
                files = try?
                filemanager.contentsOfDirectory(atPath:path) else {
            return [];
        }
        
        var availableModels: [Model] = []
        for filename in files where
        filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        return availableModels
    }()
    
    var body: some View {
        
        
        //MARK: Bottom aligned options
        ZStack(alignment: .bottom) {
            ARViewContainer(selectedModel: self.$selectedModel, isPlacementEnabled: self.$isPlacementEnabled)
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel)
            }
            else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
        }
        //MARK: Screen recording
        .overlay(alignment: .topTrailing) {
            //MARK: Record video button
            if !showVideo {
                Button {
                    if isRecording {
                        //Stopping record
                        Task {
                            do {
                                self.url = try await stopRecording()
                                print(self.url)
                                isRecording = false
                                showVideo = true
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                    }
                    else {
                        //Starting record
                        startRecording {
                            error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            //Success
                            isRecording = true
                        }
                    }
                    
                } label: {

                    Image(systemName: isRecording ? "record.circle.fill":"record.circle")
                        .font(.system(size: 50))
                        .foregroundColor(isRecording ? .red : .blue)
                }
                .padding()
            }
            else {
                //MARK: View the recorded video button
                Button {
                    showVideoPlay = true
                } label: {
                    Text("  Preview  ")
                        .frame(height: 60)
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .background(Color.white.opacity(0.75))
                        .cornerRadius(20)
                        .padding(.all, 16)
                }
                .padding()
                
                if showVideoPlay {
                    VideoPlayer(player: AVPlayer(url: self.url!))
                }
            }
            
            
        }
        
        
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(action: {
                        print("DEBUG: selected model with name \(self.models[index].modelName)")
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var body: some View {
        HStack {
            //cancelled button
            Button(action: {
                print("DEBUG: Model placement cancelled")
                self.resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }

            Text("  Tap anywhere on the screen to place the selected model on the horizontal plane.  ")
                .frame(height: 60)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .background(Color.white.opacity(0.75))
                .cornerRadius(20)
                .padding(.all, 16)
        }
        
    }
    func resetPlacementParameters () {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//MARK: AR view
struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedModel: Model?
    @Binding var isPlacementEnabled: Bool
    
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        //start AR view
        ARViewController.shared.startARSession()
        
        return ARViewController.shared.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.selectedModel {
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene - \(model.modelName)")
                ARViewController.shared.setModelEntityAndReconizeTap(modelEntity: modelEntity)
            }
            else {
                print("DEBUG: Unable to load model to scene - \(model.modelName)")
            }

            DispatchQueue.main.async {
                self.selectedModel = nil
            }
        } else {
            print("DEBUG: Model not placed yet")
        }
    }
    
}
