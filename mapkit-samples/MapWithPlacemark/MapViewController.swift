//
//  MapViewController.swift
//  MapWithPlacemark
//

import UIKit
import MappableMobile

class MapViewController: UIViewController {
    // MARK: - Public methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create new map view

        mapView = MMKMapView(frame: view.frame)

        // Add map to the view

        view.addSubview(mapView)

        // Interface to manipulate with the map

        map = mapView.mapWindow.map

        // Additional map setup

        move()
        addPlacemark()
    }

    // MARK: - Private methods

    /// Sets the map to specified point, zoom, azimuth and tilt
    private func move(to cameraPosition: MMKCameraPosition = Const.cameraPosition) {
        map.move(with: cameraPosition, animation: MMKAnimation(type: .smooth, duration: 1.0))
    }

    /// Adds a placemark to the map
    private func addPlacemark() {
        let image = UIImage(named: "icon_dollar")!
        let placemark = map.mapObjects.addPlacemark()
        placemark.geometry = Const.point
        placemark.setIconWith(image)

        // Add text with style to the placemark

        placemark.setTextWithText(
            "Sample placemark",
            style: MMKTextStyle(
                size: 10.0,
                color: .black,
                outlineWidth: 1.0,
                outlineColor: .white,
                placement: .top,
                offset: 0.0,
                offsetFromIcon: true,
                textOptional: false
            )
        )

        // Make placemark draggable

        placemark.isDraggable = true

        // Add placemark tap handler

        placemark.addTapListener(with: mapObjectTapListener)
    }

    // MARK: - Private properties

    private var mapView: MMKMapView!
    private var map: MMKMap!

    /// Handles map object taps
    /// - Note: This should be declared as property to store a strong reference
    private lazy var mapObjectTapListener: MMKMapObjectTapListener = MapObjectTapListener(controller: self)

    // MARK: - Private nesting

    /// Handles map object taps
    final private class MapObjectTapListener: NSObject, MMKMapObjectTapListener {
        init(controller: UIViewController) {
            self.controller = controller
        }

        func onMapObjectTap(with mapObject: MMKMapObject, point: MMKPoint) -> Bool {
            AlertPresenter.present(
                from: controller,
                with: "Tapped point",
                message: "\((point.latitude, point.longitude))"
            )
            print("Tapped point \((point.latitude, point.longitude))")
            return true
        }

        private weak var controller: UIViewController?
    }

    private enum Const {
        static let point = MMKPoint(latitude: 25.198176, longitude: 55.272924)
        static let cameraPosition = MMKCameraPosition(target: point, zoom: 17.0, azimuth: 150.0, tilt: 30.0)
    }
}
