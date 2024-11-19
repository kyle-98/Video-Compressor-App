//
//  VIdeoViewModel.swift
//  VideoCompressor
//
//  Created by Kyle on 11/15/24.
//

import SwiftUI
import Combine

class VideoViewModel: ObservableObject {
    @Published var selectedVideoURL: URL?
    @Published var compressedVideoURL: URL?
    @Published var isCompressing: Bool = false
    @Published var outputMessage: String?
    
    func pickVideo() {
        VideoPickerService.showPicker { url in
            self.selectedVideoURL = url
        }
    }
    
    func compressVideo() {
        guard let selectedVideoURL = selectedVideoURL else {
            outputMessage = "No video selected to compress."
            return
        }
        
        isCompressing = true
        outputMessage = nil
        
        VideoCompressionService.compressVideo(inputURL: selectedVideoURL) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCompressing = false
                switch result {
                case .success:
                    self?.outputMessage = "Video successfully saved to Photos."
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.outputMessage = nil
                    }
                case .failure(let error):
                    self?.outputMessage = "Compression failed: \(error.localizedDescription)"
                }
                
                self?.selectedVideoURL = nil
            }
        }
    }
}
