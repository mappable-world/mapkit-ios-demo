//
//  MapCameraListener.swift
//  MapSearch
//
//  Created by Daniil Pustotin on 22.08.2023.
//

import MappableMobile

class MapCameraListener: NSObject, MMKMapCameraListener {
    // MARK: - Constructor

    init(searchViewModel: SearchViewModel) {
        self.searchViewModel = searchViewModel
    }

    // MARK: - Public methods

    func onCameraPositionChanged(
        with map: MMKMap,
        cameraPosition: MMKCameraPosition,
        cameraUpdateReason: MMKCameraUpdateReason,
        finished: Bool
    ) {
        if cameraUpdateReason == .gestures {
            searchViewModel.setVisibleRegion(with: map.visibleRegion)
        }
    }

    // MARK: - Private properties

    private let searchViewModel: SearchViewModel
}
