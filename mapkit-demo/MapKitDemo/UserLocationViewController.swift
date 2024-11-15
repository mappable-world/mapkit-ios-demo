import UIKit
import MappableMobile

/**
 * This example shows how to display and customize user location arrow on the map.
 */
class UserLocationViewController: BaseMapViewController, MMKUserLocationObjectListener {

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapWindow.map.isRotateGesturesEnabled = false
        mapView.mapWindow.map.move(with:
            MMKCameraPosition(target: MMKPoint(latitude: 0, longitude: 0), zoom: 14, azimuth: 0, tilt: 0))

        let scale = UIScreen.main.scale
        let mapKit = MMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)

        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
        userLocationLayer.setAnchorWithAnchorNormal(
            CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.5 * mapView.frame.size.height * scale),
            anchorCourse: CGPoint(x: 0.5 * mapView.frame.size.width * scale, y: 0.83 * mapView.frame.size.height * scale))
        userLocationLayer.setObjectListenerWith(self)
    }

    func onObjectAdded(with view: MMKUserLocationView) {
        view.arrow.setIconWith(UIImage(named:"UserArrow")!)

        let pinPlacemark = view.pin.useCompositeIcon()

        pinPlacemark.setIconWithName("icon",
            image: UIImage(named:"Icon")!,
            style:MMKIconStyle(
                anchor: CGPoint(x: 0, y: 0) as NSValue,
                rotationType:MMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 0,
                flat: true,
                visible: true,
                scale: 1.5,
                tappableArea: nil))

        pinPlacemark.setIconWithName(
            "pin",
            image: UIImage(named:"SearchResult")!,
            style:MMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType:MMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 1,
                flat: true,
                visible: true,
                scale: 1,
                tappableArea: nil))

        view.accuracyCircle.fillColor = UIColor.blue
    }

    func onObjectRemoved(with view: MMKUserLocationView) {}

    func onObjectUpdated(with view: MMKUserLocationView, event: MMKObjectEvent) {}
}
