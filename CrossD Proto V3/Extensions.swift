//
//  Extensions.swift
//  CrossD Proto V3
//
//  Created by Surabhi Verma on 25/07/2022.
//

import SwiftUI
import ReplayKit

//MARK: App Recording Extensions
extension View {
    
    func startRecording(enableMicrophone: Bool=true, completion: @escaping (Error?)->()) {
        
        let recorder = RPScreenRecorder.shared()
        
        recorder.isMicrophoneEnabled = false
        
        recorder.startRecording(handler: completion)
    }
    
    func stopRecording() async throws -> URL {
        let name = UUID().uuidString + ".mov"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        
        let recorder = RPScreenRecorder.shared()
        
        try await recorder.stopRecording(withOutput: url)
        
        return url
    }
}
