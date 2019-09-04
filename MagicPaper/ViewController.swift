//
//  ViewController.swift
//  MagicPaper
//
//  Created by Daniel Coria on 8/22/19.
//  Copyright © 2019 iOS-DC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

struct TrackedImage {
    var name : String?
    var node : SCNNode?
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var trackedImages = [TrackedImage]()
    
    var isMyAmazingButStillJitteryNodeVisible = false
    var screenCenter: CGPoint {
        return sceneView.center
    }
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // background event
        NotificationCenter.default.addObserver(self, selector: #selector(setPlayerLayerToNil), name: .NSExtensionHostDidEnterBackground, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "NewsPaperImages", bundle: Bundle.main) {
            
            configuration.trackingImages = trackedImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        // Run the view's session
        print("tracking images count\(configuration.trackingImages.count)")
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
       
        guard let planeAnchor = anchor as? ARImageAnchor else {
            return }
        
        DispatchQueue.main.async { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            node.addChildNode(strongSelf.createNode(imageAnchor: planeAnchor))
            strongSelf.trackedImages.append(TrackedImage(name: planeAnchor.name, node: node))
            
        }
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let node = SCNNode()
//
//        guard let imageAnchor = anchor as? ARImageAnchor else{ return nil}
//
//        DispatchQueue.main.async { [weak self] () -> Void in
//            guard let strongSelf = self else { return }
//            node.addChildNode(strongSelf.createNode(imageAnchor: imageAnchor))
//        }
//
//        return node
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if(!node.isHidden){
            player?.play()
        }else{
            
            player?.seek(to: .zero)
            player?.pause()
            player = nil
            playerLayer = nil
        }
//        for currentNode in node.childNodes{
//            for(index, currentTrackedImage) in trackedImages.enumerated(){
//                if(currentNode.name == currentTrackedImage.name){
//
//                    //player = currentTrackedImage
//                    if(!node.isHidden){
//                        //guard let imageAnchor = anchor as? ARImageAnchor else{ return }
//                        //currentTrackedImage.player?.play()
//                        player?.play()
//                    }else{
//                        //currentTrackedImage.player?.pause()
//                        player?.seek(to: .zero)
//                        player?.pause()
//                    }
//
//                }else{
//                    node.removeFromParentNode()
//                    player = nil
//                    guard let planeAnchor = anchor as? ARImageAnchor else {
//                        return }
//                    DispatchQueue.main.async { [weak self] () -> Void in
//                        guard let strongSelf = self else { return }
//                        node.addChildNode(strongSelf.createNode(imageAnchor: planeAnchor))
//                        strongSelf.trackedImages.append(TrackedImage(name: planeAnchor.name, node: node))
//
//                    }
//                }
//
//            }
//        }
        
//        for(index, currentTrackedImage) in trackedImages.enumerated(){
//            //let currentTrackedImage = tracked
//            if(trackedImages.count > 1){
//                if(currentTrackedImage.node != node){
//                    player?.seek(to: .zero)
//                    player?.pause()
//                    player = nil
//                    trackedImages.remove(at: index)
//
//                    //currentTrackedImage.player = nil
//                }
//                //trackedImages.append(currentTrackedImage)
//            }
//            if(currentTrackedImage.node == node){
//
//                if(!node.isHidden){
//                    //guard let imageAnchor = anchor as? ARImageAnchor else{ return }
//                    //currentTrackedImage.player?.play()
//                    player?.play()
//                }else{
//                    //currentTrackedImage.player?.pause()
//                    player?.seek(to: .zero)
//                    player?.pause()
//                }
//            }
//        }
    }
    
    func createNode(imageAnchor: ARImageAnchor) -> SCNNode {
        
        let referenceImage = imageAnchor.referenceImage
        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
        // falta agregar pausa cuando desaparece
        
        //plane.firstMaterial?.diffuse.contents = createScene(videoNode: setupPlayerView(reference: imageAnchor))
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi/2
        return planeNode
        
    }
    
    func createScene(videoNode: SKVideoNode) -> SKScene{
        let videoScene = SKScene(size: CGSize(width: 640, height: 360))
        videoNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
        videoNode.yScale = -1.0
        videoScene.name = videoNode.name
        videoScene.addChild(videoNode)
        return videoScene
    }
    
    func setupPlayerView(reference: ARImageAnchor) -> SKVideoNode{
        player = AVPlayer(url: Bundle.main.url(forResource: "\(reference.referenceImage.name!)", withExtension: "mp4")!)
        let videoNode = SKVideoNode(avPlayer:player!)
        videoNode.name = reference.referenceImage.name!
        playerLayer = AVPlayerLayer(player: player)
        //player?.play()
        
        return videoNode
    }
    
    // background event
    @objc fileprivate func setPlayerLayerToNil(){
        // first pause the player before setting the playerLayer to nil. The pause works similar to a stop button
        player?.pause()
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}

extension AVPlayer{
    
    var isPlaying: Bool{
        return rate != 0 && error == nil
    }
}
