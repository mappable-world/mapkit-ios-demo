//
//  MapViewController.swift
//  MapInteraction
//
//  Created by Daniil Pustotin on 10.07.2023.
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

        // Setup buttons

        setupSubviews()

        // Setup map's focus

        updateMapFocus()

        // Interface to manipulate with the map

        map = mapView.mapWindow.map

        // Additional map setup

        move()

        // Setup map handlers

        let geoObjectTapListener = GeoObjectTapListener(map: map, controller: self)
        self.geoObjectTapListener = geoObjectTapListener

        map.addTapListener(with: geoObjectTapListener)

        // Add placemark

        addPlacemark()

        // Add polyline

        addPolyline()

        // Add buttons handlers

        plusZoomButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        minusZoomButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        moveToPlacemarkButton.addTarget(self, action: #selector(moveToPlacemark), for: .touchUpInside)
        moveToPolylineButton.addTarget(self, action: #selector(moveToPolyline), for: .touchUpInside)
    }

    // MARK: - Private methods

    /// Sets the map to specified point, zoom, azimuth and tilt
    private func move(to cameraPosition: MMKCameraPosition = Const.startPosition) {
        map.move(with: cameraPosition, animation: MMKAnimation(type: .smooth, duration: 1.0))
    }

    /// Sets the map to specified geometry
    private func move(to geometry: MMKGeometry) {
        let cameraPosition = map.cameraPosition(with: geometry)

        map.move(with: cameraPosition, animation: MMKAnimation(type: .smooth, duration: 1.0))
    }

    /// Updates map focus
    private func updateMapFocus() {
        let scale = Float(UIScreen.main.scale)

        mapView.mapWindow.focusRect = MMKScreenRect(
            topLeft: MMKScreenPoint(x: 0.0, y: 0.0),
            bottomRight: MMKScreenPoint(
                x: Float(view.frame.width - (Layout.buttonSize + Layout.buttonMargin)) * scale,
                y: Float(view.frame.height) * scale
            )
        )

        mapView.mapWindow.focusPoint = MMKScreenPoint(
            x: Float(view.frame.midX - (Layout.buttonSize + Layout.buttonMargin) / 2) * scale,
            y: Float(view.frame.midY) * scale
        )
    }

    /// Zooms in the map by one step
    @objc
    private func zoomIn() {
        changeZoom(by: 1.0)
    }

    /// Zooms out the map by one step
    @objc
    private func zoomOut() {
        changeZoom(by: -1.0)
    }

    /// Changes the map's zoom by the given amount
    /// - Parameter amount: The amount to change the map's zoom by
    private func changeZoom(by amount: Float) {
        guard let map = map else {
            return
        }
        map.move(
            with: MMKCameraPosition(
                target: map.cameraPosition.target,
                zoom: map.cameraPosition.zoom + amount,
                azimuth: map.cameraPosition.azimuth,
                tilt: map.cameraPosition.tilt
            ),
            animation: MMKAnimation(type: .smooth, duration: 1.0)
        )
    }

    @objc
    private func moveToPlacemark() {
        if let geometry = placemark?.geometry {
            move(
                to: MMKCameraPosition(
                    target: geometry,
                    zoom: map.cameraPosition.zoom,
                    azimuth: map.cameraPosition.azimuth,
                    tilt: map.cameraPosition.tilt
                )
            )
        }
    }

    @objc
    private func moveToPolyline() {
        if let polyline = polyline {
            move(to: MMKGeometry(polyline: polyline))
        }
    }

    /// Adds a placemark to the map
    private func addPlacemark() {
        let image = UIImage(named: "icon_dollar")!
        let placemark = map.mapObjects.addPlacemark()
        placemark.geometry = Const.startPoint
        placemark.setIconWith(image)

        self.placemark = placemark

        // Make placemark draggable

        placemark.isDraggable = true

        // Add map listener

        let inputListener = InputListener(placemark: placemark)
        self.inputListener = inputListener

        map.addInputListener(with: inputListener)
    }

    /// Adds a polyline to the map
    private func addPolyline() {
        let polyline = MMKPolyline(points: Const.polylinePoints)
        self.polyline = polyline

        map.mapObjects.addPolyline(with: polyline)
    }

    // MARK: - Private properties

    private let buttonsContainer = UIStackView()
    private let plusZoomButton = UIButton()
    private let minusZoomButton = UIButton()
    private let moveToPlacemarkButton = UIButton()
    private let moveToPolylineButton = UIButton()

    private var mapView: MMKMapView!
    private var map: MMKMap!
    private var placemark: MMKPlacemarkMapObject?
    private var polyline: MMKPolyline?

    /// Handles geo objects taps
    /// - Note: This should be declared as property to store a strong reference
    private var geoObjectTapListener: GeoObjectTapListener?

    /// Handles map inputs
    /// - Note: This should be declared as property to store a strong reference
    private var inputListener: InputListener?

    // MARK: - Private nesting

    /// Handles geoobjects taps
    final private class GeoObjectTapListener: NSObject, MMKLayersGeoObjectTapListener {
        func onObjectTap(with event: MMKGeoObjectTapEvent) -> Bool {
            guard let map = map, let controller = controller,
                  let point = event.geoObject.geometry.first?.point else {
                return true
            }

            let cameraPosition = map.cameraPosition
            map.move(
                with: MMKCameraPosition(
                    target: point,
                    zoom: cameraPosition.zoom,
                    azimuth: cameraPosition.azimuth,
                    tilt: cameraPosition.tilt
                ),
                animation: MMKAnimation(type: .smooth, duration: 1.0)
            )

            let name = event.geoObject.name ?? "Unnamed geoObject"

            AlertPresenter.present(
                from: controller,
                with: "Tapped \(name)",
                message: "\((point.latitude, point.longitude))"
            )

            return true
        }

        init(map: MMKMap, controller: UIViewController) {
            self.map = map
            self.controller = controller
        }

        private weak var map: MMKMap?
        private weak var controller: UIViewController?
    }

    /// Handles map inputs
    final private class InputListener: NSObject, MMKMapInputListener {
        init(placemark: MMKPlacemarkMapObject) {
            self.placemark = placemark
        }

        func onMapTap(with map: MMKMap, point: MMKPoint) {}

        func onMapLongTap(with map: MMKMap, point: MMKPoint) {
            placemark.geometry = point
        }

        private let placemark: MMKPlacemarkMapObject
    }

    private enum Const {
        static let startPoint = MMKPoint(latitude: 25.196862, longitude: 55.274684)

        static let startPosition = MMKCameraPosition(
            target: startPoint,
            zoom: 14.0,
            azimuth: .zero,
            tilt: .zero
        )

        static let polylinePoints = [
            MMKPoint(latitude: 25.185258, longitude: 55.277641),
            MMKPoint(latitude: 25.191593, longitude: 55.268581),
            MMKPoint(latitude: 25.194521, longitude: 55.267103),
            MMKPoint(latitude: 25.194521, longitude: 55.267103),
            MMKPoint(latitude: 25.199055, longitude: 55.273207),
            MMKPoint(latitude: 25.200917, longitude: 55.277665),
            MMKPoint(latitude: 25.194865, longitude: 55.288942),
            MMKPoint(latitude: 25.190461, longitude: 55.282314)
        ]
    }

    // MARK: - Layout

    private enum Layout {
        static let buttonSize: CGFloat = 48.0
        static let buttonMargin: CGFloat = 16.0
        static let buttonCornerRadius: CGFloat = 8.0
    }

    /// Setups buttons layout
    private func setupSubviews() {
        view.addSubview(buttonsContainer)
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false

        buttonsContainer.spacing = Layout.buttonMargin
        buttonsContainer.axis = .vertical

        [
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.buttonMargin),
            buttonsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        .forEach { $0.isActive = true }

        [plusZoomButton, minusZoomButton, moveToPlacemarkButton, moveToPolylineButton].forEach {
            buttonsContainer.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Palette.background
            $0.layer.cornerRadius = Layout.buttonCornerRadius

            [
                $0.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
                $0.heightAnchor.constraint(equalToConstant: Layout.buttonSize)
            ]
            .forEach { $0.isActive = true }
        }

        plusZoomButton.setImage(UIImage(systemName: "plus"), for: .normal)
        minusZoomButton.setImage(UIImage(systemName: "minus"), for: .normal)
        moveToPlacemarkButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        moveToPolylineButton.setImage(UIImage(systemName: "hexagon"), for: .normal)
    }
}
