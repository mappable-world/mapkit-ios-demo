//
//  RouteViewStyleProvider.swift
//

import MappableMobile
import MMKStylingAutomotiveNavigation
import MMKStylingRoadEvents

final class RouteViewStyleProvider: NSObject, MMKNavigationRouteViewStyleProvider {
    // MARK: - Constructor

    init(carNavigationStyleProvider: MMKAutomotiveNavigationStyleProvider, styleManager: NavigationStyleManager) {
        self.carNavigationStyleProvider = carNavigationStyleProvider
        self.styleManager = styleManager
    }

    // MARK: - Public methods

    func provideJamStyle(
        with flags: MMKDrivingFlags,
        isSelected: Bool,
        isNightMode: Bool,
        navigationLayerMode: MMKNavigationLayerMode,
        jamStyle: MMKNavigationJamStyle
    ) {
        carNavigationStyleProvider
            .routeViewStyleProvider()
            .provideJamStyle(
                with: flags,
                isSelected: isSelected,
                isNightMode: isNightMode,
                navigationLayerMode: navigationLayerMode,
                jamStyle: jamStyle
            )
    }

    func providePolylineStyle(
        with flags: MMKDrivingFlags,
        isSelected: Bool,
        isNightMode: Bool,
        navigationLayerMode: MMKNavigationLayerMode,
        polylineStyle: MMKPolylineStyle
    ) {
        carNavigationStyleProvider
            .routeViewStyleProvider()
            .providePolylineStyle(
                with: flags,
                isSelected: isSelected,
                isNightMode: isNightMode,
                navigationLayerMode: navigationLayerMode,
                polylineStyle: polylineStyle
            )
    }

    func provideManoeuvreStyle(
        with flags: MMKDrivingFlags,
        isSelected: Bool,
        isNightMode: Bool,
        navigationLayerMode: MMKNavigationLayerMode,
        arrowStyle: MMKArrowStyle
    ) {
        carNavigationStyleProvider
            .routeViewStyleProvider()
            .provideManoeuvreStyle(
                with: flags,
                isSelected: isSelected,
                isNightMode: isNightMode,
                navigationLayerMode: navigationLayerMode,
                arrowStyle: arrowStyle
            )
    }

    func provideRouteStyle(
        with flags: MMKDrivingFlags,
        isSelected: Bool,
        isNightMode: Bool,
        navigationLayerMode: MMKNavigationLayerMode,
        routeStyle: MMKNavigationRouteStyle
    ) {
        carNavigationStyleProvider
            .routeViewStyleProvider()
            .provideRouteStyle(
                with: flags,
                isSelected: isSelected,
                isNightMode: isNightMode,
                navigationLayerMode: navigationLayerMode,
                routeStyle: routeStyle
            )

        let showJams = {
            switch styleManager.currentJamsMode {
            case .disabled:
                return false

            case .enabled:
                return true

            case .enabledForCurrentRoute:
                return isSelected
            }
        }()

        routeStyle.setShowJamsWithShowJams(showJams)

        if !flags.predicted {
            routeStyle.setShowRouteWithShowRoute(true)
            routeStyle.setShowTrafficLightsWithShowTrafficLights(styleManager.trafficLightsVisibility && isSelected)
            routeStyle.setShowRoadEventsWithShowRoadEvents(styleManager.roadEventsOnRouteVisibility && isSelected)
            routeStyle.setShowBalloonsWithShowBalloons(styleManager.balloonsVisibility)
            routeStyle.setShowManoeuvresWithShowManoeuvres(isSelected)
        } else {
            routeStyle.setShowRouteWithShowRoute(styleManager.predictedVisibility)
            routeStyle.setShowTrafficLightsWithShowTrafficLights(false)
            routeStyle.setShowRoadEventsWithShowRoadEvents(styleManager.roadEventsOnRouteVisibility)
            routeStyle.setShowBalloonsWithShowBalloons(false)
            routeStyle.setShowManoeuvresWithShowManoeuvres(false)
        }
    }

    // MARK: - Private propeties

    private let carNavigationStyleProvider: MMKAutomotiveNavigationStyleProvider
    private let styleManager: NavigationStyleManager
}
