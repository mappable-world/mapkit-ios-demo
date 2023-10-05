//
//  MapInputListener.swift
//  MapRouting
//
//  Created by Daniil Pustotin on 28.08.2023.
//

import MappableMobile

final class MapInputListener: NSObject, MMKMapInputListener {
    init(routingViewModel: RoutingViewModel) {
        self.routingViewModel = routingViewModel
    }

    func onMapTap(with map: MMKMap, point: MMKPoint) {}

    func onMapLongTap(with map: MMKMap, point: MMKPoint) {
        routingViewModel.addRoutePoint(point)
    }

    private let routingViewModel: RoutingViewModel
}
