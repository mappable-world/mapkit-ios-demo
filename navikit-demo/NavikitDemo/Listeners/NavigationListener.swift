//
//  NavigationListener.swift
//

import MappableMobile

final class NavigationListener: NSObject, MMKNavigationListener {
    func onRoutesRequested(with points: [MMKRequestPoint]) {
    }

    func onAlternativesRequested(withCurrentRoute currentRoute: MMKDrivingRoute) {
    }

    func onUriResolvingRequested(withUri uri: String) {
    }

    func onMatchRouteResolvingRequested() {
    }

    func onParkingRoutesRequested() {
    }

    func onRoutesBuilt() {
    }

    func onRoutesRequestErrorWithError(_ error: Error) {
    }

    func onResetRoutes() {
    }
}
