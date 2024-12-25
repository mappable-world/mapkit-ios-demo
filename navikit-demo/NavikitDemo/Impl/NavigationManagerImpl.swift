//
//  NavigationManagerImpl.swift
//

import Combine
import MappableMobile

final class NavigationManagerImpl: NSObject, NavigationManager, ObservableObject {
    // MARK: - Public properties

    var status = CurrentValueSubject<GuidanceStatus, Never>(.stopped)

    var routeFinished = PassthroughSubject<Void, Never>()

    var roadName = CurrentValueSubject<String, Never>(String())

    var roadFlags = CurrentValueSubject<String, Never>(String())

    var upcomingManeuvers = CurrentValueSubject<[MMKNavigationUpcomingManoeuvre], Never>([])

    var upcomingLaneSigns = CurrentValueSubject<[MMKNavigationUpcomingLaneSign], Never>([])

    var currentRoute = CurrentValueSubject<MMKDrivingRoute?, Never>(nil)

    var speedLimit: MMKLocalizedValue? {
        navigation.guidance.speedLimit
    }

    var speedLimitStatus: MMKSpeedLimitStatus {
        navigation.guidance.speedLimitStatus
    }

    // MARK: - Constructor

    init(
        navigation: MMKNavigation,
        locationManager: LocationManager,
        simulationManager: SimulationManager,
        vehicleOptionManager: VehicleOptionsProvider,
        settingsRepository: SettingsRepository
    ) {
        self.navigation = navigation
        self.locationManager = locationManager
        self.simulationManager = simulationManager
        self.vehicleOptionManager = vehicleOptionManager
        self.settingsRepository = settingsRepository

        upcomingManeuvers.value = navigation.guidance.windshield.manoeuvres
        upcomingLaneSigns.value = navigation.guidance.windshield.laneSigns
        currentRoute.value = navigation.guidance.currentRoute
    }

    func serializeNavigation() {
        let serializedNavigation = MMKNavigationSerialization.serialize(navigation)
            .base64EncodedString()

        settingsRepository.serializedNavigation.send(serializedNavigation)
    }

    func requestRoutes(points: [MMKRequestPoint]) {
        navigation.vehicleOptions = vehicleOptionManager.vehicleOptions
        navigation.requestRoutes(
            with: requestPointsFromCurrent(via: points),
            routeOptions: MMKAutomotiveRouteOptions(
                initialAzimuth: locationManager.location.value?.heading,
                routesCount: nil)
        )
    }

    func startGuidance(route: MMKDrivingRoute) {
        if navigation.routes.contains(where: { $0.routeId == route.routeId }) ||
            navigation.guidance.currentRoute == nil {
            navigation.startGuidance(with: route)
        }

        if let route = navigation.guidance.currentRoute {
            simulationManager.start(route: route)
        }

        status.send(.started)
    }

    func stopGuidance() {
        navigation.stopGuidance()
        navigation.resetRoutes()

        if simulationManager.isSimulationActive.value {
            simulationManager.stop()
        }

        status.send(.stopped)
    }

    func resume() {
        navigation.resume()
        if simulationManager.isSimulationActive.value {
            simulationManager.resume()
        }
    }

    func suspend() {
        navigation.suspend()
        if simulationManager.isSimulationActive.value {
            simulationManager.suspend()
        }
    }

    func start() {
        navigation.guidance.addListener(with: guidanceListener)
        navigation.guidance.windshield.addListener(with: windshieldListener)
    }

    // MARK: - Private methods

    private func requestPointsFromCurrent(via points: [MMKRequestPoint]) -> [MMKRequestPoint] {
        guard let location = locationManager.location.value?.position else {
            return []
        }
        return [
            MMKRequestPoint(point: location, type: .waypoint, pointContext: nil, drivingArrivalPointId: nil, indoorLevelId: nil)
        ] + points
    }

    // MARK: - Private properties

    private let locationManager: LocationManager
    fileprivate let navigation: MMKNavigation
    private let simulationManager: SimulationManager
    private let vehicleOptionManager: VehicleOptionsProvider
    private let settingsRepository: SettingsRepository

    private lazy var guidanceListener = NavigationManagerGuidanceListener(navigationManager: self)
    private lazy var windshieldListener = NavigationManagerWindshieldListener(navigationManager: self)
}

private class NavigationManagerGuidanceListener: BasicGuidanceListener {
    init(navigationManager: NavigationManagerImpl) {
        self.navigationManager = navigationManager
    }

    override func onCurrentRouteChanged(with reason: MMKRouteChangeReason) {
        guard let navigationManager else {
            return
        }
        navigationManager.currentRoute.send(navigationManager.navigation.guidance.currentRoute)
    }

    override func onRouteFinished() {
        navigationManager?.routeFinished.send()
    }

    override func onRoadNameChanged() {
        guard let navigationManager else {
            return
        }
        navigationManager.roadName.send(navigationManager.navigation.guidance.roadName ?? String())
    }

    private weak var navigationManager: NavigationManagerImpl?
}

private class NavigationManagerWindshieldListener: NSObject, MMKNavigationWindshieldListener {
    init(navigationManager: NavigationManagerImpl) {
        self.navigationManager = navigationManager
    }

    func onManoeuvresChanged() {
        guard let navigationManager else {
            return
        }
        navigationManager.upcomingManeuvers.send(navigationManager.navigation.guidance.windshield.manoeuvres)
    }

    func onLaneSignChanged() {
        guard let navigationManager else {
            return
        }
        navigationManager.upcomingLaneSigns.send(navigationManager.navigation.guidance.windshield.laneSigns)
    }

    func onDirectionSignChanged() {}

    func onRoadEventsChanged() {}

    private weak var navigationManager: NavigationManagerImpl?
}
