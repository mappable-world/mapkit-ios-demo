//
//  MapObjectTapListener.swift
//  MapObjects
//

import MappableMobile

final class MapObjectTapListener: NSObject, MMKMapObjectTapListener {
    // MARK: - Constructor

    init(controller: UIViewController) {
        self.controller = controller
    }

    // MARK: - Public methods

    func onMapObjectTap(with mapObject: MMKMapObject, point: MMKPoint) -> Bool {
        let alertTitle: String
        let alertMessage: String

        switch mapObject {
        case let polylineObject as MMKPolylineMapObject:
            polylineObject.setStrokeColorWith(PolylineColorPalette.color)
            alertTitle = "Tapped the polyline"
            alertMessage = "Changed color"
        case let circleObject as MMKCircleMapObject:
            let circleGeometry = GeometryProvider.circleWithRandomRadius
            circleObject.geometry = circleGeometry
            alertTitle = "Tapped the circle"
            alertMessage = "Changed radius to \(circleGeometry.radius)"
        default:
            alertTitle = "Tapped the placemark"
            alertMessage = String(describing: mapObject.userData)
        }

        AlertPresenter.present(
            from: controller,
            with: alertTitle,
            message: alertMessage
        )
        return true
    }

    // MARK: - Private properties

    private weak var controller: UIViewController?
}
