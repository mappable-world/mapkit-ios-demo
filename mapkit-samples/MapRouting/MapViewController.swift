//
//  MapViewController.swift
//  MapRouting
//

import UIKit
import MappableMobile

class MapViewController: UIViewController {
    // MARK: - Public methods

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MMKMapView(frame: view.frame)
        view.addSubview(mapView)
        map = mapView.mapWindow.map

        map.addInputListener(with: mapInputListener)

        routingViewModel.placemarksCollection = map.mapObjects.add()
        routingViewModel.routesCollection = map.mapObjects.add()

        move()

        setupSubviews()

        Const.defaultPoints
            .forEach { routingViewModel.addRoutePoint($0) }
    }

    // MARK: - Private methods

    private func move(to cameraPosition: MMKCameraPosition = Const.startPosition) {
        map.move(with: cameraPosition, animation: MMKAnimation(type: .smooth, duration: 1.0))
    }

    private func setupSubviews() {
        view.addSubview(resetRoutePointsButton)
        resetRoutePointsButton.translatesAutoresizingMaskIntoConstraints = false

        resetRoutePointsButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        resetRoutePointsButton.backgroundColor = Palette.background
        resetRoutePointsButton.layer.cornerRadius = Layout.buttonCornerRadius

        resetRoutePointsButton.addTarget(self, action: #selector(handleResetRoutePointsButtonTap), for: .touchUpInside)

        [
            resetRoutePointsButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize),
            resetRoutePointsButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
            resetRoutePointsButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Layout.buttonMargin
            ),
            resetRoutePointsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Layout.buttonMargin)
        ]
        .forEach { $0.isActive = true }
    }

    @objc
    private func handleResetRoutePointsButtonTap() {
        routingViewModel.resetRoutePoints()
    }

    // MARK: - Private properties

    private var mapView: MMKMapView!
    private var map: MMKMap!

    private lazy var routingViewModel = RoutingViewModel(controller: self)
    private lazy var mapInputListener: MMKMapInputListener = MapInputListener(routingViewModel: routingViewModel)

    private let resetRoutePointsButton = UIButton()

    // MARK: - Private nesting

    private enum Const {
        static let startPoint = MMKPoint(latitude: 25.1980, longitude: 55.272758)
        static let startPosition = MMKCameraPosition(target: startPoint, zoom: 13.0, azimuth: .zero, tilt: .zero)

        static let defaultPoints: [MMKPoint] = [
            MMKPoint(latitude: 25.196141, longitude: 55.278543),
            MMKPoint(latitude: 25.171148, longitude: 55.238034)
        ]
    }

    private enum Layout {
        static let buttonSize: CGFloat = 50.0
        static let buttonMargin: CGFloat = 50.0
        static let buttonCornerRadius: CGFloat = 8.0
    }
}
