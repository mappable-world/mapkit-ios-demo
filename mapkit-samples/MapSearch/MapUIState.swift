//
//  MapUIState.swift
//  MapSearch
//
//  Created by Daniil Pustotin on 14.08.2023.
//

import MappableMobile

struct MapUIState {
    let query: String
    let searchState: SearchState
    let suggestState: SuggestState

    init(query: String = String(), searchState: SearchState, suggestState: SuggestState) {
        self.query = query
        self.searchState = searchState
        self.suggestState = suggestState
    }
}

struct SearchResponseItem {
    let point: MMKPoint
    let geoObject: MMKGeoObject?
}

enum SearchState {
    case idle
    case loading
    case error
    case success(items: [SearchResponseItem], zoomToItems: Bool, itemsBoundingBox: MMKBoundingBox)
}

enum SuggestState {
    case idle
    case loading
    case error
    case success(items: [SuggestItem])
}
