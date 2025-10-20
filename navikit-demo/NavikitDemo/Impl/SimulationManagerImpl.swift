//
//  SimulationManagerImpl.swift
//

import Combine
import MappableMobile

final class SimulationManagerImpl: NSObject, SimulationManager, MMKLocationSimulatorListener {
    // MARK: - Public properties

    var simulationFinished = PassthroughSubject<Void, Never>()

    var isSimulationActive = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Constructor

    init(settingsRepository: SettingsRepository) {
        self.settingsRepository = settingsRepository
    }

    // MARK: - Public methods

    func start(route: MMKDrivingRoute) {
        self.speed = Double(settingsRepository.simulationSpeed.value)

        locationSimulator = MMKMapKit.sharedInstance().createLocationSimulator()
        locationSimulator.subscribeForSimulatorEvents(with: self)
        
        let locationSettings = MMKLocationSettingsFactory.coarseSettings()
        locationSettings.speed = speed
        let simulationSettings =
            [MMKSimulationSettings(geometry: route.geometry, locationSettings: locationSettings)]
        MMKMapKit.sharedInstance().setLocationManagerWith(locationSimulator)

        locationSimulator.startSimulation(withSettings: simulationSettings)
        isSimulationActive.send(true)
    }

    func onSimulationFinished() {
        stop()
    }

    func stop() {
        locationSimulator?.unsubscribeFromSimulatorEvents(with: self)
        locationSimulator = nil
        MMKMapKit.sharedInstance().resetLocationManagerToDefault()
        isSimulationActive.send(false)
        simulationFinished.send(())
    }

    func resume() {
        locationSimulator?.resume()
    }

    func suspend() {
        locationSimulator?.suspend()
    }

    func setSpeed(with speed: Double) {
        self.speed = speed
        locationSimulator?.speed = speed
    }

    // MARK: - Private properties

    private var speed: Double = 20.0

    private var locationSimulator: MMKLocationSimulator!

    private let settingsRepository: SettingsRepository
}
