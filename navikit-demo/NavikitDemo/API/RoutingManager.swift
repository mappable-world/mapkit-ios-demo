//
//  RoutingManager.swift
//

import MappableMobile

protocol RoutingManager: AnyObject {
    // MARK: - Public methods

    func addRoutePoint(_ point: MMKPoint, type: MMKRequestPointType)
}
