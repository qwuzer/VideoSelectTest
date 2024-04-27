//
//  ContentView.swift
//  VideoSelectTest
//
//  Created by William Chang on 2023/11/15.
//

import SwiftUI
import UIKit
import MobileCoreServices
import AVFoundation
import Combine


struct VideoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedVideoURL: URL?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                parent.selectedVideoURL = videoURL

            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}


struct ContentView: View {
    @State private var isVideoPickerPresented = false
    @State private var selectedVideoURL: URL?
    @State private var processedVideoURL: URL? // New state for processed video
    @State private var uploadProgress: Float = 0.0 // Track upload progress
    
    private var videoProcessingManager = VideoProcessingManager()
    private var poseDetectorManager = PoseDetectorManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Pick a Video") {
                    isVideoPickerPresented = true
                    print("Pick a video")
                }
                ProgressBar(value: $uploadProgress)
                
                if let videoURL = processedVideoURL {
                    VideoPlayerView(url: videoURL)
                        .frame(height: 300)
                    Text("Processed Video")
                        .font(.headline)
                        .padding(.top, 5)
                } else if let videoURL = selectedVideoURL {
                    VideoPlayerView(url: videoURL)
                        .frame(height: 300)
                    Text("Original Video")
                        .font(.headline)
                        .padding(.top, 5)
                } else {
                    Text("No video selected")
                        .font(.headline)
                        .padding(.top, 5)
                }
        
//                if let videoURL = processedVideoURL ?? selectedVideoURL {
//                    VideoPlayerView(url: videoURL)
//                        .frame(height: 300)
//                    Text(videoURL == processedVideoURL ? "Processed Video" : "Original Video")
//                        .font(.headline)
//                        .padding(.top, 5)
//                }
            }
            .navigationTitle("Library")
            .sheet(isPresented: $isVideoPickerPresented) {
                 VideoPicker(isPresented: $isVideoPickerPresented, selectedVideoURL: $selectedVideoURL)
            }
            .onChange(of: selectedVideoURL) { selectedVideoURL in
                if let videoURL = selectedVideoURL {
                    processVideo(url: videoURL)
                }
            }

            
        }
    }

    private func processVideo(url: URL) {
        print("ProcessVideo function is operating!")
        print("url:\(url)")
        extractFrames(from: url) { frames in
            if frames.isEmpty {
                print("frames is empty")
            }
            var processedFrames: [UIImage] = []

            let group = DispatchGroup()
            for frame in frames {
                group.enter()
                poseDetectorManager.processImage(frame) { [self] poses, error in
                    
                    defer {
                        group.leave()
                    }
                    
                    guard let poses = poses, error == nil else {
                        print("Error processing image: \(error)")
//                        group.leave()
                        return
                    }

                    let processedFrame = videoProcessingManager.drawSkeleton(on: frame, using: poses)
                    processedFrames.append(processedFrame)
                    if processedFrames.isEmpty {
                        print("processedFrames is empty")
                    }
//                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("Processed Frames Count: \(processedFrames.count)")
                // Here, all frames have been processed, and you can now rebuild the video
                videoProcessingManager.createVideo(from: processedFrames, originalVideoURL: url) { newVideoURL in
                    self.processedVideoURL = newVideoURL
//                    print(self.$processedVideoURL)
                }
            }
        }
    }
}
    

struct ProgressBar: View {
    @Binding var value: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width, height: 8)
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: 8)
                    .animation(.linear)
            }
        }
        .cornerRadius(4)
        .padding()
    }
}
 
func extractFrames(from url: URL, completion: @escaping ([UIImage]) -> Void) {
    //display in log
    print("    Starting frame extraction for URL: \(url)")
    DispatchQueue.global(qos: .userInitiated).async {
        var frames: [UIImage] = []
        let asset = AVAsset(url: url)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.requestedTimeToleranceBefore = .zero
        assetGenerator.requestedTimeToleranceAfter = .zero

        let track = asset.tracks(withMediaType: .video).first!
        let frameRate = track.nominalFrameRate
        let duration = asset.duration.seconds
        
        print("video framerate : \(frameRate)")
        let frameInterval = 1.0 / Double(frameRate)
        print("duratoin : \(duration)")
        
        for timeInSeconds in stride(from: 0, to: duration, by: frameInterval) {
            let cmTime = CMTime(seconds: timeInSeconds, preferredTimescale: 600)
            do {
                let cgImage = try assetGenerator.copyCGImage(at: cmTime, actualTime: nil)
                let frame = UIImage(cgImage: cgImage)
                frames.append(frame)
            } catch {
                print("Error extracting frame at time \(timeInSeconds): \(error)")
            }
        }

        DispatchQueue.main.async {
            print("Extracted \(frames.count) frames from the video.")
            completion(frames)
        }
    }
}

//#Preview
