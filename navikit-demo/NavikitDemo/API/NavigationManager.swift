//
//  NavigationManager.swift
//

import Combine
import MappableMobile

protocol NavigationManager {
    // MARK: - Public properties

    var status: CurrentValueSubject<GuidanceStatus, Never> { get }
    var routeFinished: PassthroughSubject<Void, Never> { get }
    var roadName: CurrentValueSubject<String, Never> { get }
    var roadFlags: CurrentValueSubject<String, Never> { get }
    var upcomingManeuvers: CurrentValueSubject<[MMKNavigationUpcomingManoeuvre], Never> { get }
    var upcomingLaneSigns: CurrentValueSubject<[MMKNavigationUpcomingLaneSign], Never> { get }
    var currentRoute: CurrentValueSubject<MMKDrivingRoute?, Never> { get }
    var speedLimit: MMKLocalizedValue? { get }
    var speedLimitStatus: MMKSpeedLimitStatus { get }

    // MARK: - Public methods

    func serializeNavigation()
    func requestRoutes(points: [MMKRequestPoint])
    func startGuidance(route: MMKDrivingRoute)
    func stopGuidance()
    func resume()
    func suspend()
    func start()
}
