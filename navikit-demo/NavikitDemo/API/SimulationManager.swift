//
//  SimulationManager.swift
//

import Combine
import MappableMobile

protocol SimulationManager {
    // MARK: - Public properties

    var simulationFinished: PassthroughSubject<Void, Never> { get }
    var isSimulationActive: CurrentValueSubject<Bool, Never> { get }

    // MARK: - Public methods

    func start(route: MMKDrivingRoute)
    func stop()
    func resume()
    func suspend()
    func setSpeed(with speed: Double)
}
