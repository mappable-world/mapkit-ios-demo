//
//  LocationManager.swift
//

import Combine
import MappableMobile

protocol LocationManager: MMKGuidanceListener {
    // MARK: - Public properties

    var location: CurrentValueSubject<MMKLocation?, Never> { get }

    // MARK: - Public methods

    func addGuidanceListener()
    func removeGuidanceListener()
}
