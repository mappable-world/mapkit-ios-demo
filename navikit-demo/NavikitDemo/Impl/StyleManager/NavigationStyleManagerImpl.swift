//
//  NavigationStyleManagerImpl.swift
//

import MappableMobile
import MMKStylingAutomotiveNavigation
import MMKStylingRoadEvents

final class NavigationStyleManagerImpl: NSObject, NavigationStyleManager {
    var trafficLightsVisibility = true

    var roadEventsOnRouteVisibility = true

    var balloonsVisibility = true

    var predictedVisibility = true

    var currentJamsMode: JamsMode = .enabledForCurrentRoute

    func routeViewStyleProvider() -> MMKNavigationRouteViewStyleProvider {
        internalRouteViewStyleProvider
    }

    func balloonImageProvider() -> MMKNavigationBalloonImageProvider {
        carNavigationStyleProvider.balloonImageProvider()
    }

    func requestPointStyleProvider() -> MMKNavigationRequestPointStyleProvider {
        carNavigationStyleProvider.requestPointStyleProvider()
    }

    func userPlacemarkStyleProvider() -> MMKNavigationUserPlacemarkStyleProvider {
        carNavigationStyleProvider.userPlacemarkStyleProvider()
    }

    func routePinsStyleProvider() -> MMKNavigationRoutePinsStyleProvider {
        carNavigationStyleProvider.routePinsStyleProvider()
    }

    func highlight() -> MMKHighlightStyleProvider {
        carNavigationStyleProvider.highlight()
    }

    // MARK: - Private properties

    private let carNavigationStyleProvider = MMKAutomotiveNavigationStyleProvider()

    private lazy var internalRouteViewStyleProvider = RouteViewStyleProvider(
        carNavigationStyleProvider: carNavigationStyleProvider,
        styleManager: self
    )
}
