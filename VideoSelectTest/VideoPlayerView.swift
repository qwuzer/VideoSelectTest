//
//  VideoPlayerView.swift
//  VideoSelectTest
//
//  Created by William Chang on 2023/11/16.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update the view controller if needed.
    }
}
