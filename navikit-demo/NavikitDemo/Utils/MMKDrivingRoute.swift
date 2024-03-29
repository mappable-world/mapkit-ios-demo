//
//  MMKDrivingRoute.swift
//

import MappableMobile

public extension MMKDrivingRoute {
    var timeWithTraffic: MMKLocalizedValue {
        metadata.weight.timeWithTraffic
    }

    var distanceLeft: MMKLocalizedValue {
        metadata.weight.distance
    }
}
