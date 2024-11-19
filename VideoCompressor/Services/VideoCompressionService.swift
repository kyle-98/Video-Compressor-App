//
//  VideoCompressionService.swift
//  VideoCompressor
//
//  Created by Kyle on 11/15/24.
//

import AVFoundation
import Photos

struct VideoCompressionService {
    static func compressVideo(inputURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let asset = AVURLAsset(url: inputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(.failure(NSError(domain: "VideoCompressionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot create export session"])))
            return
        }
        
        let outputDirectory = FileManager.default.temporaryDirectory
        let outputFileURL = outputDirectory.appendingPathComponent("compressed_video.mp4")
        
        // Remove existing file
        if FileManager.default.fileExists(atPath: outputFileURL.path) {
            do {
                try FileManager.default.removeItem(at: outputFileURL)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        exportSession.outputURL = outputFileURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        Task {
            do {
                try await exportSession.export()
                
                // Handle export completion
                if exportSession.status == .completed {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                    }) { success, error in
                        if let error = error {
                            completion(.failure(error))
                        } else if success {
                            completion(.success(()))
                        } else {
                            completion(.failure(NSError(domain: "VideoCompressionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error saving video to Photos"])))
                        }
                        
                        // Clean up temporary file
                        try? FileManager.default.removeItem(at: outputFileURL)
                    }
                } else if let error = exportSession.error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "VideoCompressionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Video export failed for unknown reasons"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
