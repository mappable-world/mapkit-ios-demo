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
        locationSimulator = MMKMapKit.sharedInstance().createLocationSimulator(withGeometry: route.geometry)

        locationSimulator.subscribeForSimulatorEvents(with: self)
        locationSimulator.speed = speed

        MMKMapKit.sharedInstance().setLocationManagerWith(locationSimulator)

        locationSimulator.startSimulation(with: .coarse)
        isSimulationActive.send(true)

        setSpeed(with: Double(settingsRepository.simulationSpeed.value))
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
