import UIKit
import Foundation
import MappableMobile

/**
 * This is a basic example that displays a map and sets camera focus on the target location.
 * You need to specify your API key in the AppDelegate.swift file before working with the map.
 * Note: When working on your projects, remember to request the required permissions.
 */
class MapViewController: BaseMapViewController {
    
    let TARGET_LOCATION = MMKPoint(latitude: 25.229762, longitude: 55.289311)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapWindow.map.move(
            with: MMKCameraPosition(target: TARGET_LOCATION, zoom: 15, azimuth: 0, tilt: 0),
            animationType: MMKAnimation(type: MMKAnimationType.smooth, duration: 5),
            cameraCallback: nil)
    }
}
