import MLKit
import AVFoundation
import UIKit

class VideoProcessingManager {
    
    
    var angleData: [[String: Double]] = []//array used to be output later
    
    
    func drawSkeleton(on frame: UIImage, using poses: [Pose]) -> UIImage {
        print("Start draw skeleton")
        UIGraphicsBeginImageContext(frame.size)
        frame.draw(at: CGPoint.zero)
        
        var count = 0;
        for pose in poses {
            // Draw landmarks and lines
            let landmarks = pose.landmarks
            //            landmarks.forEach { landmark in
            //                drawCircle(at: landmark.position, on: frame)
            //            }
            
            
            let positions: [VisionPoint] = [pose.landmark(ofType: .leftKnee).position,
                                            pose.landmark(ofType: .rightKnee).position,
                                            pose.landmark(ofType: .leftHip).position,
                                            pose.landmark(ofType: .rightHip).position,
                                            pose.landmark(ofType: .leftShoulder).position,
                                            pose.landmark(ofType: .rightShoulder).position,
                                            pose.landmark(ofType: .leftAnkle).position,
                                            pose.landmark(ofType: .rightAnkle).position,
                                            pose.landmark(ofType: .leftHeel).position,
                                            pose.landmark(ofType: .rightHeel).position,
                                            pose.landmark(ofType: .leftToe).position,
                                            pose.landmark(ofType: .rightToe).position
            ]
            for p in positions
            {
                if( p != pose.landmark(ofType: .leftShoulder).position &&
                    p != pose.landmark(ofType: .rightShoulder).position &&
                    p != pose.landmark(ofType: .leftHip).position &&
                    p != pose.landmark(ofType: .rightHip).position &&
                    p != pose.landmark(ofType: .rightAnkle).position &&
                    p != pose.landmark(ofType: .leftAnkle).position)
                {
                    drawCircle(at: p, on: frame)
                }
                
            }
            
            let middleShoulderX = (pose.landmark(ofType: .leftShoulder).position.x + pose.landmark(ofType: .rightShoulder).position.x) / 2
            let middleShoulderY = (pose.landmark(ofType: .leftShoulder).position.y + pose.landmark(ofType: .rightShoulder).position.y) / 2
            let middleHipX = (pose.landmark(ofType: .leftHip).position.x + pose.landmark(ofType: .rightHip).position.x) / 2
            let middleHipY = (pose.landmark(ofType: .leftHip).position.y + pose.landmark(ofType: .rightHip).position.y) / 2
            drawCircle(atX: middleShoulderX, y: middleShoulderY, on: frame)
            drawCircle(atX: middleHipX, y: middleHipY, on: frame)
            
            // Connect landmarks to draw the skeleton
            // Example: Connect shoulder landmarks
            if let leftShoulder = landmarks.first(where: { $0.type == .leftShoulder }),
               let rightShoulder = landmarks.first(where: { $0.type == .rightShoulder }),
               let rightHip = landmarks.first(where : {$0.type == .rightHip}),
               let leftHip = landmarks.first(where : {$0.type == .leftHip})
            {
                //Shoulder to Hip line
                drawLine(from:( leftShoulder.position.x + rightShoulder.position.x)/2, startY:( leftShoulder.position.y + rightShoulder.position.y)/2, to: (rightHip.position.x + leftHip.position.x)/2 , endY: (rightHip.position.y + leftHip.position.y)/2, on: frame)
                //Hip to knees
                drawLine(from: middleHipX, startY: middleHipY, to: pose.landmark(ofType: .rightKnee).position.x, endY: pose.landmark(ofType: .rightKnee).position.y, on: frame)
                drawLine(from: middleHipX, startY: middleHipY, to: pose.landmark(ofType: .leftKnee).position.x, endY: pose.landmark(ofType: .leftKnee).position.y, on: frame)
                //knee to heels
                drawLine(from: pose.landmark(ofType: .rightKnee).position.x, startY: pose.landmark(ofType: .rightKnee).position.y, to: pose.landmark(ofType: .rightHeel).position.x, endY: pose.landmark(ofType: .rightHeel).position.y, on: frame)
                drawLine(from: pose.landmark(ofType: .leftKnee).position.x, startY: pose.landmark(ofType: .leftKnee).position.y, to: pose.landmark(ofType: .leftHeel).position.x, endY: pose.landmark(ofType: .leftHeel).position.y, on: frame)
                //heels to toes
                drawLine(from: pose.landmark(ofType: .rightHeel).position.x, startY: pose.landmark(ofType: .rightHeel).position.y, to: pose.landmark(ofType: .rightToe).position.x, endY: pose.landmark(ofType: .rightToe).position.y, on: frame)
                drawLine(from: pose.landmark(ofType: .leftHeel).position.x, startY: pose.landmark(ofType: .leftHeel).position.y, to: pose.landmark(ofType: .leftToe).position.x, endY: pose.landmark(ofType: .leftToe).position.y, on: frame)
                
                
                
                print("leftKnee: ",pose.landmark(ofType: .leftKnee).position.x,pose.landmark(ofType: .leftKnee).position.y)
                print("rightKnee: ",pose.landmark(ofType: .rightKnee).position.x,pose.landmark(ofType: .rightKnee).position.y)
                print("centerHip: ",(pose.landmark(ofType: .leftHip).position.x + pose.landmark(ofType: .rightHip).position.x)/2,(pose.landmark(ofType: .leftHip).position.y + pose.landmark(ofType: .rightHip).position.y)/2)
                
                let xlknee = pose.landmark(ofType: .leftKnee).position.x
                let xrknee = pose.landmark(ofType: .rightKnee).position.x
                let xmhip = (pose.landmark(ofType: .leftHip).position.x + pose.landmark(ofType: .rightHip).position.x)/2
                let xmshldr = (pose.landmark(ofType: .leftShoulder).position.x + pose.landmark(ofType: .rightShoulder).position.x)/2
                let xrtoe = pose.landmark(ofType: .rightToe).position.x
                let xltoe = pose.landmark(ofType: .leftToe).position.x
                let xrheel = pose.landmark(ofType: .rightHeel).position.x
                let xlheel = pose.landmark(ofType: .leftHeel).position.x
                
                let ylknee = pose.landmark(ofType: .leftKnee).position.y
                let yrknee = pose.landmark(ofType: .rightKnee).position.y
                let ymhip = (pose.landmark(ofType: .leftHip).position.y + pose.landmark(ofType: .rightHip).position.y)/2
                let ymshldr = (pose.landmark(ofType: .leftShoulder).position.y + pose.landmark(ofType: .rightShoulder).position.y)/2
                let yrtoe = pose.landmark(ofType: .rightToe).position.y
                let yltoe = pose.landmark(ofType: .leftToe).position.y
                let yrheel = pose.landmark(ofType: .rightHeel).position.y
                let ylheel = pose.landmark(ofType: .leftHeel).position.y
                
                
                print("Angle(lknee-hip-rknee): ",calculate_angle(x1: xlknee, x2: xmhip, x3: xrknee, y1: ylknee, y2: ymhip, y3: yrknee))
                print("Angle(shlder-hip-rknee):" , calculate_angle(x1: xmshldr, x2: xmhip, x3: xrknee, y1: ymshldr, y2: ymhip, y3: yrknee))
                print("Angle(shlder-hip-lknee):" , calculate_angle(x1: xmshldr, x2: xmhip, x3: xlknee, y1: ymshldr, y2: ymhip, y3: ylknee))
                print("Angle(rknee-rheel-rtoe) : ", calculate_angle(x1: xrknee, x2: xrheel, x3: xrtoe, y1: yrknee, y2: yrheel, y3: yrtoe))
                print("Angle(lknee-lheel-ltoe) : ", calculate_angle(x1: xlknee, x2: xlheel, x3: xltoe, y1: ylknee, y2: ylheel, y3: yltoe))
                
                let angles: [String: Double] = [
                    "Angle_lknee_hip_rknee": calculate_angle(x1: xlknee, x2: ylknee, x3: xmhip, y1: ymhip, y2: xrknee, y3: yrknee),
                    "Angle_shlder_hip_rknee": calculate_angle(x1: xmshldr, x2: ymshldr, x3: xmhip, y1: ymhip, y2: xrknee, y3: yrknee),
                    "Angle_shlder_hip_lknee": calculate_angle(x1: xmshldr, x2: ymshldr, x3: xmhip, y1: ymhip, y2: xlknee, y3: ylknee),
                       // ... add other angles ...
                   ]
                angleData.append(angles)
                    
            }
            // Add more connections as needed
        }
        
        print(angleData)
        
        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
            
        print("Finish draw skeleton")
        return processedImage ?? frame
    }
    
    //For vision points that are defined in the landmarks
    private func drawCircle(at point: VisionPoint, on image: UIImage) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.addEllipse(in: CGRect(x: point.x, y: point.y, width: 10, height: 10))
        context.setFillColor(UIColor.red.cgColor)
        context.fillPath()
    }
    
    private func drawCircle(atX x: CGFloat, y: CGFloat, on image: UIImage) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.addEllipse(in: CGRect(x: x, y: y, width: 10, height: 10))
        context.setFillColor(UIColor.red.cgColor)
        context.fillPath()
    }
    
    private func drawLine(from start: VisionPoint, to end: VisionPoint, on image: UIImage) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.move(to: CGPoint(x: start.x, y: start.y))
        context.addLine(to: CGPoint(x: end.x, y: end.y))
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
    }
    
    private func drawLine(from startX: CGFloat, startY: CGFloat, to endX: CGFloat, endY: CGFloat, on image: UIImage) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.move(to: CGPoint(x: startX, y: startY))
        context.addLine(to: CGPoint(x: endX, y: endY))
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
    }

    
   
    private func calculate_angle(x1: Double,x2: Double, x3: Double,y1: Double,y2: Double,y3: Double) -> Double {
        if (x1 == x2 && x2 == x3) || ( y1 == y2 && y2 == y3){
            return 0
        }
        
        let radians1 = atan2(y1 - y2, x1 - x2)
        let radians2 = atan2(y3 - y2, x3 - x2)

        
        var angle = abs(radians1 - radians2) * 180 / .pi
        
        if angle > 180 {
            angle = 360 - angle
        }
        
        return angle
    }
    
    
    func processFrame(_ frame: UIImage) {
        // Assuming pose detection returns a Pose object
        PoseDetectorManager().processImage(frame) { pose, error in
            guard let pose = pose, error == nil else { return }
            
            let processedFrame = self.drawSkeleton(on: frame, using: pose)
            // Store or use this processed frame
        }
    }
    
    
    func createVideo(from processedFrames: [UIImage], originalVideoURL: URL, completion: @escaping (URL?) -> Void) {
           //let outputURL = ... // Define the URL for the new video file
            let outputURL: URL = {
                let tempDirectory = NSTemporaryDirectory()
                let fileName = UUID().uuidString + ".mp4" // Unique file name
                let url = URL(fileURLWithPath: tempDirectory).appendingPathComponent(fileName)
                return url
            }()

            print("outputURL: ",outputURL)
           guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
               print("Error1")
               completion(nil)
               return
           }

        if processedFrames.isEmpty {
            print("Error2: processedFrames is empty")
            completion(nil)
            return
        }
        
           guard let firstImage = processedFrames.first else {
               print("Error2")
               completion(nil)
               return
           }

           let frameSize = firstImage.size
           let videoSettings: [String: Any] = [
               AVVideoCodecKey: AVVideoCodecType.h264.rawValue,
               AVVideoWidthKey: frameSize.width,
               AVVideoHeightKey: frameSize.height
           ]

           let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
           let sourcePixelBufferAttributes: [String: Any] = [
               String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32ARGB),
               String(kCVPixelBufferWidthKey): frameSize.width,
               String(kCVPixelBufferHeightKey): frameSize.height
           ]
           let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
           
           videoWriter.add(writerInput)
           videoWriter.startWriting()
           videoWriter.startSession(atSourceTime: .zero)

           writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoQueue")) {
               let frameDuration = CMTimeMake(value: 1, timescale: Int32(30)) // Adjust frame rate if needed
               var frameCount = 0

               for image in processedFrames {
                   while !writerInput.isReadyForMoreMediaData {}
                   if let pixelBuffer = self.pixelBuffer(from: image) {
                       let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(30)) // Match the timescale with frame duration
                       pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: frameTime)
                       frameCount += 1
                   } else {
                       print("Failed to convert UIImage to pixel buffer")
                       break
                   }
               }

               writerInput.markAsFinished()
               videoWriter.finishWriting {
                   switch videoWriter.status {
                   case .completed:
                       completion(outputURL)
                   default:
                       print("Failed to write video: \(videoWriter.error?.localizedDescription ?? "unknown error")")
                       completion(nil)
                   }
               }
           }
       }
    
    private func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(image.size.width),
            Int(image.size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        guard let cgImage = image.cgImage else {
            return nil
        }

        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }


}
