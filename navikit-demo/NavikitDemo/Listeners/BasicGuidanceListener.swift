//
//  BasicGuidanceListener.swift
//

import MappableMobile

class BasicGuidanceListener: NSObject, MMKGuidanceListener {
    func onLocationChanged() {}

    func onCurrentRouteChanged(with reason: MMKRouteChangeReason) {}

    func onRouteLost() {}

    func onReturnedToRoute() {}

    func onRouteFinished() {}

    func onWayPointReached() {}

    func onStandingStatusChanged() {}

    func onRoadNameChanged() {}

    func onSpeedLimitUpdated() {}

    func onSpeedLimitStatusUpdated() {}

    func onAlternativesChanged() {}

    func onFastestAlternativeChanged() {}
}
