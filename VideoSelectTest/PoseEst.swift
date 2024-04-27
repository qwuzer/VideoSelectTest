//
//  PoseEst.swift
//  VideoSelectTest
//
//  Created by William Chang on 2023/11/16.
//

import Foundation
import MLKit


class PoseDetectorManager {
    private let poseDetector: PoseDetector

    init() {
        // Use PoseDetectorOptions for a more accurate but slower detector
        // or AccuratePoseDetectorOptions for faster but less accurate results
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .singleImage // Use for single image processing
        poseDetector = PoseDetector.poseDetector(options: options)
    }
}

extension PoseDetectorManager {
    func processImage(_ image: UIImage, completion: @escaping ([Pose]?, Error?) -> Void) {
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation

        poseDetector.process(visionImage) { poses, error in
            completion(poses, error)
        }
    }
}

