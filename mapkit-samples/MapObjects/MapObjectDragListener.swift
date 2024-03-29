//
//  MapObjectDragListener.swift
//  MapObjects
//

import UIKit
import MappableMobile

final class MapObjectDragListener: NSObject, MMKMapObjectDragListener {
    // MARK: - Constructor

    init(controller: UIViewController, clusterizedCollection: MMKClusterizedPlacemarkCollection) {
        self.controller = controller
        self.clusterizedCollection = clusterizedCollection
    }

    // MARK: - Public methods

    func onMapObjectDragStart(with mapObject: MMKMapObject) {
        AlertPresenter.present(from: controller, with: "Drag event started")
    }

    func onMapObjectDrag(with mapObject: MMKMapObject, point: MMKPoint) {}

    func onMapObjectDragEnd(with mapObject: MMKMapObject) {
        AlertPresenter.present(from: controller, with: "Drag event ended")

        clusterizedCollection.clusterPlacemarks(
            withClusterRadius: GeometryProvider.clusterRadius,
            minZoom: GeometryProvider.clusterMinZoom
        )
    }

    // MARK: - Private properties

    private weak var controller: UIViewController?
    private var clusterizedCollection: MMKClusterizedPlacemarkCollection
}
