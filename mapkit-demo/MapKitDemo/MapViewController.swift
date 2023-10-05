import UIKit
import Foundation
import MappableMobile

/**
 * This is a basic example that displays a map and sets camera focus on the target location.
 * You need to specify your API key in the AppDelegate.swift file before working with the map.
 * Note: When working on your projects, remember to request the required permissions.
 */
class MapViewController: BaseMapViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapWindow.map.move(
            with: MMKCameraPosition(target: Const.targetLocation, zoom: 15, azimuth: 0, tilt: 0),
            animation: MMKAnimation(type: MMKAnimationType.smooth, duration: 5),
            cameraCallback: nil)
    }
}
