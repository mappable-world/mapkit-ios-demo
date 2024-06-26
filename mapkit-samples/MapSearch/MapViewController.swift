//
//  MapViewController.swift
//  MapSearch
//

import Combine
import UIKit
import MappableMobile

class MapViewController: UIViewController {
    // MARK: - Public methods

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MMKMapView(frame: view.frame)
        view.addSubview(mapView)

        map = mapView.mapWindow.map

        map.addCameraListener(with: mapCameraListener)

        searchViewModel.setupSubscriptions()

        setupSearchController()

        moveToStartPoint()
    }

    // MARK: - Private methods

    private func moveToStartPoint() {
        map.move(with: Const.startPosition, animation: MMKAnimation(type: .smooth, duration: 0.5))
        searchViewModel.setVisibleRegion(with: map.visibleRegion)
    }

    private func setupSearchController() {
        self.searchBarController.searchResultsUpdater = self
        self.searchBarController.obscuresBackgroundDuringPresentation = true
        self.searchBarController.hidesNavigationBarDuringPresentation = false
        self.searchBarController.searchBar.placeholder = "Search places"

        self.navigationItem.searchController = searchBarController
        self.definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false

        searchBarController.delegate = self
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.showsBookmarkButton = false

        setupStateUpdates()
    }

    private func focusCamera(points: [MMKPoint], boundingBox: MMKBoundingBox) {
        if points.isEmpty {
            return
        }

        let position = points.count == 1
            ? MMKCameraPosition(
                target: points.first!,
                zoom: map.cameraPosition.zoom,
                azimuth: map.cameraPosition.azimuth,
                tilt: map.cameraPosition.tilt
            )
            : map.cameraPosition(with: MMKGeometry(boundingBox: boundingBox))

        map.move(with: position, animation: MMKAnimation(type: .smooth, duration: 0.5))
    }

    private func displaySearchResults(
        items: [SearchResponseItem],
        zoomToItems: Bool,
        itemsBoundingBox: MMKBoundingBox
    ) {
        map.mapObjects.clear()

        items.forEach { item in
            let image = UIImage(systemName: "circle.circle.fill")!
                .withTintColor(.tintColor)

            let placemark = map.mapObjects.addPlacemark()
            placemark.geometry = item.point
            placemark.setViewWithView(MRTViewProvider(uiView: UIImageView(image: image)))

            placemark.userData = item.geoObject
            placemark.addTapListener(with: mapObjectTapListener)
        }
    }

    // MARK: - Private properties

    private var mapView: MMKMapView!
    private lazy var map: MMKMap = mapView.mapWindow.map
    private let buttonsView = UIStackView()
    private lazy var mapCameraListener = MapCameraListener(searchViewModel: searchViewModel)

    private let searchBarController = UISearchController()
    private let searchViewModel = SearchViewModel()
    private var bag = Set<AnyCancellable>()

    @Published private var searchSuggests: [SuggestItem] = []

    private lazy var mapObjectTapListener = MapObjectTapListener(controller: self)

    // MARK: - Private nesting

    private enum Const {
        static let startPoint = MMKPoint(latitude: 25.198200, longitude: 55.272758)
        static let startPosition = MMKCameraPosition(target: startPoint, zoom: 13.0, azimuth: .zero, tilt: .zero)
    }

    // MARK: - Layout

    private enum Layout {
        static let buttonSize: CGFloat = 50.0
    }
}

extension MapViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchViewModel.reset()
        searchViewModel.setQueryText(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchViewModel.startSearch()
        searchBarController.searchBar.text = searchViewModel.mapUIState.query
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if case .idle = searchViewModel.mapUIState.searchState {
            updatePlaceholder()
        }
    }

    func updateSearchResults(for searchController: UISearchController, selecting searchSuggestion: UISearchSuggestion) {
        guard let item = searchSuggestion.representedObject as? SuggestItem else {
            return
        }

        item.onClick()
    }

    func setupStateUpdates() {
        searchViewModel.$mapUIState.sink { [weak self] state in
            let query = state?.query ?? String()
            self?.searchBarController.searchBar.text = query
            self?.updatePlaceholder(with: query)

            if case let .success(items, zoomToItems, itemsBoundingBox) = state?.searchState {
                self?.displaySearchResults(items: items, zoomToItems: zoomToItems, itemsBoundingBox: itemsBoundingBox)
                if zoomToItems {
                    self?.focusCamera(points: items.map { $0.point }, boundingBox: itemsBoundingBox)
                }
            }
            if let suggestState = state?.suggestState {
                self?.updateSuggests(with: suggestState)
            }
        }
        .store(in: &bag)
    }

    private func updateSuggests(with suggestState: SuggestState) {
        switch suggestState {
        case .success(let items):
            searchBarController.searchSuggestions = items.map { item in
                let title = AttributedString(item.title.text)
                let subtitle = AttributedString(item.subtitle?.text ?? "")
                    .settingAttributes(
                        AttributeContainer([.foregroundColor: UIColor.secondaryLabel])
                    )

                let suggestString = NSAttributedString(title + AttributedString(" ") + subtitle)

                let suggest = UISearchSuggestionItem(localizedAttributedSuggestion: suggestString)
                suggest.representedObject = item
                return suggest
            }

        default:
            return
        }
    }

    private func updatePlaceholder(with text: String = String()) {
        searchBarController.searchBar.placeholder = text.isEmpty ? "Search places" : text
    }
}
