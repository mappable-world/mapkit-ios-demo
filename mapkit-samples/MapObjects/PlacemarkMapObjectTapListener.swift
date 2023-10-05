//
//  PlacemarkMapObjectTapListener.swift
//  MapObjects
//
//  Created by Daniil Pustotin on 03.08.2023.
//

import MappableMobile

final class PlacemarkMapObjectTapListener: NSObject, MMKMapObjectTapListener {
    // MARK: - Constructor

    init(controller: UIViewController, alertTitle: String) {
        self.controller = controller
        self.alertTitle = alertTitle
    }

    // MARK: - Public methods

    func onMapObjectTap(with mapObject: MMKMapObject, point: MMKPoint) -> Bool {
        AlertPresenter.present(from: controller, with: alertTitle)
        return true
    }

    // MARK: - Private properties

    private weak var controller: UIViewController?
    private let alertTitle: String
}
