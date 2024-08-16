import UIKit
import MappableMobile

/**
 * This example shows how to add and interact with a layer that displays search results on the map.
 * Note: search API calls count towards MapKit daily usage limits.
 */
class SearchViewController: BaseMapViewController, MMKMapCameraListener {

    var searchManager: MMKSearchManager?
    var searchSession: MMKSearchSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchManager = MMKSearchFactory.instance().createSearchManager(with: .combined)

        mapView.mapWindow.map.addCameraListener(with: self)

        mapView.mapWindow.map.move(with: MMKCameraPosition(
            target: Const.targetLocation,
            zoom: 14,
            azimuth: 0,
            tilt: 0))
    }

    func onCameraPositionChanged(with map: MMKMap,
                                 cameraPosition: MMKCameraPosition,
                                 cameraUpdateReason: MMKCameraUpdateReason,
                                 finished: Bool) {
        if finished {
            let responseHandler = {(searchResponse: MMKSearchResponse?, error: Error?) -> Void in
                if let response = searchResponse {
                    self.onSearchResponse(response)
                } else {
                    self.onSearchError(error!)
                }
            }

            searchSession = searchManager!.submit(
                withText: "cafe",
                geometry: MMKVisibleRegionUtils.toPolygon(with: map.visibleRegion),
                searchOptions: MMKSearchOptions(),
                responseHandler: responseHandler)
        }
    }

    func onSearchResponse(_ response: MMKSearchResponse) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.clear()
        for searchResult in response.collection.children {
            if let point = searchResult.obj?.geometry.first?.point {
                mapObjects.addPlacemark() {
                    $0.geometry = point
                    $0.setIconWith(UIImage(named: "SearchResult")!)
                }
            }
        }
    }

    func onSearchError(_ error: Error) {
        let searchError = (error as NSError).userInfo[MRTUnderlyingErrorKey] as! MRTError
        var errorMessage = "Unknown error"
        if searchError.isKind(of: MRTNetworkError.self) {
            errorMessage = "Network error"
        } else if searchError.isKind(of: MRTRemoteError.self) {
            errorMessage = "Remote server error"
        }

        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}
