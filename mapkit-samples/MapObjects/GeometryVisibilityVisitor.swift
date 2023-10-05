//
//  GeometryVisibilityVisitor.swift
//  MapObjects
//
//  Created by Daniil Pustotin on 31.07.2023.
//

import MappableMobile

final class GeometryVisibilityVisitor: NSObject, MMKMapObjectVisitor {
    // MARK: - Construtor

    init(viewModel: GeometryVisitorViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Public methods

    func onPlacemarkVisited(withPlacemark placemark: MMKPlacemarkMapObject) {}

    func onPolylineVisited(withPolyline polyline: MMKPolylineMapObject) {
        polyline.isVisible = viewModel.isGeometryShownOnMap
    }

    func onPolygonVisited(withPolygon polygon: MMKPolygonMapObject) {
        polygon.isVisible = viewModel.isGeometryShownOnMap
    }

    func onCircleVisited(withCircle circle: MMKCircleMapObject) {
        circle.isVisible = viewModel.isGeometryShownOnMap
    }

    func onCollectionVisitStart(with collection: MMKMapObjectCollection) -> Bool {
        true
    }

    func onCollectionVisitEnd(with collection: MMKMapObjectCollection) {}

    func onClusterizedCollectionVisitStart(with collection: MMKClusterizedPlacemarkCollection) -> Bool {
        true
    }

    func onClusterizedCollectionVisitEnd(with collection: MMKClusterizedPlacemarkCollection) {}

    // MARK: - Private properties

    private var viewModel: GeometryVisitorViewModel
}
