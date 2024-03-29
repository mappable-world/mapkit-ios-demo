//
//  NavigationLayerManagerImpl.swift
//

import MappableMobile

final class NavigationLayerManagerImpl: NSObject, NavigationLayerManager, MMKRouteViewListener {
    // MARK: - Public properties

    var selectedRoute: MMKDrivingRoute? {
        navigationLayer.selectedRoute()?.route
    }

    // MARK: - Constructor

    init(navigationLayer: MMKNavigationLayer, mapViewStateManager: MapViewStateManager) {
        self.navigationLayer = navigationLayer
        self.mapViewStateManager = mapViewStateManager
    }

    // MARK: - Public methods

    func setup() {
        navigationLayer.addRouteViewListener(with: self)
    }

    func onRouteViewTap(withRoute route: MMKRouteView) {
        switch navigationLayer.routesSource {
        case .navigation:
            navigationLayer.selectRoute(withRoute: route)

        case .guidance:
            navigationLayer.navigation.guidance.switchToRoute(with: route.route)
        @unknown default:
            print("Invalid routes source - \(navigationLayer.routesSource)")
        }
    }

    func onRouteViewsChanged() {
        guard selectedRoute == nil,
              let route = navigationLayer.routes.first else {
            return
        }

        mapViewStateManager.set(state: .routeVariants)

        navigationLayer.selectRoute(withRoute: route)
    }

    // MARK: - Private properties

    private let navigationLayer: MMKNavigationLayer
    private let mapViewStateManager: MapViewStateManager
}
