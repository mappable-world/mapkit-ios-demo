import UIKit
import Foundation
import MappableMobile

/**
 * This example shows how to activate selection.
 */
class MapSelectionViewController: BaseMapViewController, MMKLayersGeoObjectTapListener, MMKMapInputListener {
    
    let TARGET_LOCATION = MMKPoint(latitude: 25.229762, longitude: 55.289311)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapWindow.map.move(
            with: MMKCameraPosition(target: TARGET_LOCATION, zoom: 17, azimuth: 0, tilt: 0),
            animationType: MMKAnimation(type: MMKAnimationType.smooth, duration: 1),
            cameraCallback: nil)
        
        mapView.mapWindow.map.addTapListener(with: self)
        mapView.mapWindow.map.addInputListener(with: self)
    }
    
    func onObjectTap(with: MMKGeoObjectTapEvent) -> Bool {
        let event = with
        let metadata = event.geoObject.metadataContainer.getItemOf(MMKGeoObjectSelectionMetadata.self)
        if let selectionMetadata = metadata as? MMKGeoObjectSelectionMetadata {
            mapView.mapWindow.map.selectGeoObject(withObjectId: selectionMetadata.id, layerId: selectionMetadata.layerId)
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
