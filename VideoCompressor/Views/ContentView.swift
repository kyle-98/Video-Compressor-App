//
//  ContentView.swift
//  VideoCompressor
//
//  Created by Kyle on 11/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = VideoViewModel()
    @State private var isShowingPicker = false
    
    var body: some View {
        VStack {
            Text("Video Compressor")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            if let selectedVideoURL = viewModel.selectedVideoURL {
                VStack {
                    Text("Video Selected:")
                        .font(.headline)
                    Text(selectedVideoURL.lastPathComponent)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                
                if viewModel.isCompressing {
                    ProgressView("Compressing...")
                        .padding()
                } else {
                    Button("Compress Video") {
                        viewModel.compressVideo()
                    }
                    .padding()
                }
            } else {
                Text("No video selected")
                    .foregroundColor(.gray)
            }
            
            Button("Pick a Video") {
                isShowingPicker = true
            }
            .sheet(isPresented: $isShowingPicker) {
                VideoPickerService.showPicker { url in
                    isShowingPicker = false
                    viewModel.selectedVideoURL = url
                }
            }
            .padding()
            
            if let compressedVideoURL = viewModel.compressedVideoURL {
                VStack {
                    Text("Compressed Video:")
                        .font(.headline)
                    Text(compressedVideoURL.lastPathComponent)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button("Play Compressed Video") {
                        // Play the compressed video
                        print("Playing video at: \(compressedVideoURL)")
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            
            if let outputMessage = viewModel.outputMessage {
                Text(outputMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}




#Preview {
    ContentView()
}
