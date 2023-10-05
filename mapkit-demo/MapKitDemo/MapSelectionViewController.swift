import UIKit
import Foundation
import MappableMobile

/**
 * This example shows how to activate selection.
 */
class MapSelectionViewController: BaseMapViewController, MMKLayersGeoObjectTapListener, MMKMapInputListener {

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapWindow.map.move(
            with: MMKCameraPosition(target: Const.targetLocation, zoom: 17, azimuth: 0, tilt: 0),
            animation: MMKAnimation(type: MMKAnimationType.smooth, duration: 1),
            cameraCallback: nil)

        mapView.mapWindow.map.addTapListener(with: self)
        mapView.mapWindow.map.addInputListener(with: self)
    }

    func onObjectTap(with: MMKGeoObjectTapEvent) -> Bool {
        let event = with
        let metadata = event.geoObject.metadataContainer.getItemOf(MMKGeoObjectSelectionMetadata.self)
        if let selectionMetadata = metadata as? MMKGeoObjectSelectionMetadata {
            mapView.mapWindow.map.selectGeoObject(withSelectionMetaData:selectionMetadata)
            return true
        }
        return false
    }

    func onMapTap(with map: MMKMap, point: MMKPoint) {
        mapView.mapWindow.map.deselectGeoObject()
    }

    func onMapLongTap(with map: MMKMap, point: MMKPoint) {
    }
}
