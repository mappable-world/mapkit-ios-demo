//
//  RoutingManagerImpl.swift
//

import MappableMobile

final class RoutingManagerImpl: BasicGuidanceListener, RoutingManager {
    // MARK: - Constructor

    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
    }

    // MARK: - Public methods

    func addRoutePoint(_ point: MMKPoint, type: MMKRequestPointType = .waypoint) {
        let requestPoint = MMKRequestPoint(point: point, type: type, pointContext: nil, drivingArrivalPointId: nil)
        switch type {
        case .waypoint:
            requestPoints = [requestPoint]

        case .viapoint:
            if requestPoints.isEmpty {
                requestPoints.append(requestPoint)
            } else {
                requestPoints.insert(requestPoint, at: requestPoints.endIndex - 1)
            }
        @unknown default:
            print("Invalid request point type - \(type)")
        }
    }

    func requestRoutes() {
        navigationManager.requestRoutes(points: requestPoints)
    }

    // MARK: - Private methods

    private func onRequestPointsChanged() {
        if !requestPoints.isEmpty {
            requestRoutes()
        }
    }

    // MARK: - Private properties

    private let navigationManager: NavigationManager

    private var requestPoints: [MMKRequestPoint] = [] {
        didSet {
            onRequestPointsChanged()
        }
    }
}
