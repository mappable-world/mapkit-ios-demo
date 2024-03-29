//
//  NavigationLayerManager.swift
//

import MappableMobile

protocol NavigationLayerManager {
    // MARK: - Public properties

    var selectedRoute: MMKDrivingRoute? { get }

    // MARK: - Public methods

    func setup()
}
