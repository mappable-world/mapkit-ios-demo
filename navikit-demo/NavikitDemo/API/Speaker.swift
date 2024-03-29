//
//  Speaker.swift
//

import Combine
import MappableMobile

protocol Speaker: MMKSpeaker {
    // MARK: - Public properties

    var phrases: CurrentValueSubject<String, Never> { get }

    // MARK: - Public methods

    func setLanguage(with language: MMKAnnotationLanguage)
}
