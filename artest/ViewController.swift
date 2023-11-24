//
//  ViewController.swift
//  artest
//
//  Created by Juwon Hyun on 2023/11/14.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var arButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    
    //1120
    //노드를 삭제하기 위해서 createnodes를 ㅏㅈㄱ성
    var createdNodes = [SCNNode]()
    var isARRunning = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 3000.0, repeats: true) { timer in
            DispatchQueue.main.async {
                for node in self.createdNodes {
                    node.removeFromParentNode()
                }
                self.createdNodes.removeAll()
            }
        }
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    /*
    @IBAction func arButtonTapped(_ sender: UIButton) {
            if isARRunning {
                sceneView.session.pause()
            } else {
                let configuration = ARWorldTrackingConfiguration()
                sceneView.session.run(configuration)
            }
            
            isARRunning = !isARRunning
        }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // create pointCloud
        guard let pointCloud = sceneView.session.currentFrame?.rawFeaturePoints else { return }
        let points = pointCloud.points
        
        // create parentnode
        let parent = SCNNode()
        
        //place the parentnode by stride()
        //from => The starting value to use for the sequence
        //to => end value to limit the sequence.
        //by =>The amount to step by with each iteration.
        // ##this function will skip some cloudPoint.##
        for i in stride(from: 0, to: points.count, by: 35){
            //print(points.count)
            //print(points)
            let point = points[i]
            let node = SCNNode()
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.yellow
            node.geometry = SCNSphere(radius: 0.0055) // 점의 크기를 설정
            node.geometry?.firstMaterial = material
            node.position = SCNVector3(point.x, point.y, point.z)

            // 생성된 노드를 부모 노드에 추가
            parent.addChildNode(node)
        }
        
        // 부모 노드를 sceneView에 추가하고, 생성한 노드를 배열에 저장
        DispatchQueue.main.async {
            self.sceneView.scene.rootNode.addChildNode(parent)
            self.createdNodes.append(parent)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
         if let planeAnchor = anchor as? ARPlaneAnchor {
                node.addChildNode(createWallNode(planeAnchor: planeAnchor))
             
             //if planeAnchor.classification == .wall{
                 //let width = CGFloat(planeAnchor.planeExtent.width)
                 //let height = CGFloat(planeAnchor.planeExtent.height)
                 //let center = planeAnchor.center
                 //let plane = SCNPlane(width: width, height: height)
                 //let planeNode = SCNNode(geometry: plane)

                 //planeNode.eulerAngles.x = -.pi / 2
                 //planeNode.position = SCNVector3(center.x, 0, center.z)
                 
                 //node.addChildNode(planeNode)
             //}
             
             /*
            카메라로부터 가장 가까운 벽의 엥커를 찾음
             if let closeAnchor = findClosestAnchorsFromCamera(){
                 let anchorForCamera = closeAnchor
                 print("Anchor 1: \(anchorForCamera)")
                 let nodeForCamera = SCNNode()
                 let materialForCamera = SCNMaterial()
                 materialForCamera.diffuse.contents = UIColor.red
                 nodeForCamera.geometry = SCNBox(width: 0.01,
                                                 height: 0.01,
                                                 length: 0.01,
                                                 chamferRadius: 0.0)
                 nodeForCamera.geometry?.materials = [materialForCamera]
                 nodeForCamera.position = SCNVector3(anchorForCamera.transform.columns.3.x,
                                                     anchorForCamera.transform.columns.3.y,
                                                     anchorForCamera.transform.columns.3.z)
                 node.addChildNode(nodeForCamera)
             }
             */
             
             
             /*
            가장 가까운 벽엥커들을 찾아서 표시
             if let closePair = findClosestAnchors(){
                 let anchor1 = closePair.0
                 let anchor2 = closePair.1
                 //print("Anchor 1: \(anchor1)")
                 //print("Anchor 2: \(anchor2)")
                 
                 let disBWA = distanceBetweenAnchors(anchor1: anchor1, anchor2: anchor2)
                 
                 //node1
                 let node1 = SCNNode()
                 let material1 = SCNMaterial()
                 material1.diffuse.contents = UIColor.blue
                 node1.geometry = SCNBox(width: 0.1,
                                         height: 0.1,
                                         length: 0.1,
                                         chamferRadius: 0.0)
                 node1.geometry?.materials = [material1]
                 node1.position = SCNVector3(anchor1.transform.columns.3.x,
                                             anchor1.transform.columns.3.y,
                                             anchor1.transform.columns.3.z)
                 node.addChildNode(node1)
                 
                 
                 //node2
                 let node2 = SCNNode()
                 let material2 = SCNMaterial()
                 material2.diffuse.contents = UIColor.red
                 node2.geometry = SCNBox(width: 0.1,
                                         height: 0.1,
                                         length: 0.1,
                                         chamferRadius: 0.0)
                 node2.geometry?.materials = [material2]
                 node2.position = SCNVector3(anchor2.transform.columns.3.x,
                                             anchor2.transform.columns.3.y,
                                             anchor2.transform.columns.3.z)
                 node.addChildNode(node2)
             }
              */
         }
     }
     
     
     
    func createWallNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
        //if planeAnchor.classification == .wall{
            let width = CGFloat(planeAnchor.planeExtent.width)
            let height = CGFloat(planeAnchor.planeExtent.height)
            let center = planeAnchor.center
            let plane = SCNPlane(width: width, height: height)
            print("From create wall node, width = \(width), height = \(height)")
            print(planeAnchor)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            let planeNode = SCNNode(geometry: plane)
            planeNode.geometry?.materials = [material]
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.position = SCNVector3(center.x, 0, center.z)
            return planeNode
        //}
        //return SCNNode()
    }
     
     
     
     func findClosestAnchors() -> (ARAnchor, ARAnchor)? {
         guard let anchors = sceneView.session.currentFrame?.anchors else{return nil}
         var minDistance = Float.greatestFiniteMagnitude
         var closePair: (ARAnchor,ARAnchor)?
         
         for i in 0..<anchors.count{
             for j in i+1..<anchors.count{
                 let distance = distanceBetweenAnchors(anchor1: anchors[i], anchor2: anchors[j])
                 if distance < minDistance {
                 minDistance = distance
                 closePair = (anchors[i], anchors[j])
                 }
             }
         }
         return closePair
     }
     
     
     func findClosestAnchorsFromCamera() -> ARAnchor? {
         guard let anchors = sceneView.session.currentFrame?.anchors,
         let cameraTransform = sceneView.session.currentFrame?.camera.transform else {return nil}
         
         var minDistance = Float.greatestFiniteMagnitude
         var closestWallAnchor : ARAnchor?
         
         for anchor in anchors {
         if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical {
             let distance = distance(transform1: cameraTransform, transform2: anchor.transform)
                 if distance < minDistance {
                 minDistance = distance
                 closestWallAnchor = anchor
                 }
             }
         }
         return closestWallAnchor
     }
     
     
     func distance(transform1:matrix_float4x4, transform2:matrix_float4x4) -> Float{
         let dx = transform1.columns.3.x - transform2.columns.3.x
         let dy = transform1.columns.3.y - transform2.columns.3.y
         let dz = transform1.columns.3.z - transform2.columns.3.z
         let distanceToAnchor = sqrt(dx*dx + dy*dy + dz*dz)
         //print("distance From Camera = \(distanceToAnchor)")
         return sqrt(dx*dx + dy*dy + dz*dz)
     }
     
     func distanceBetweenAnchors(anchor1: ARAnchor, anchor2: ARAnchor) -> Float {
         let dx = anchor1.transform.columns.3.x - anchor2.transform.columns.3.x
         let dy = anchor1.transform.columns.3.y - anchor2.transform.columns.3.y
         let dz = anchor1.transform.columns.3.z - anchor2.transform.columns.3.z
         let distanceBetweenAnchors = sqrt(dx*dx + dy*dy + dz*dz)
         //print("distance between Anchors = \(distanceBetweenAnchors)")
         return sqrt(dx*dx + dy*dy + dz*dz)
     }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}

