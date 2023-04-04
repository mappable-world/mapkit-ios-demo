import UIKit
import MappableMobile

/**
 * This example shows how to add and interact with a layer that displays search results on the map.
 * Note: search API calls count towards MapKit daily usage limits.
 */
class SearchViewController: BaseMapViewController, MMKMapCameraListener {

    var searchManager: MMKSearchManager?
    var searchSession: MMKSearchSession?
    @IBOutlet weak var searchEdit: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchManager = MMKSearch.sharedInstance().createSearchManager(with: .combined)
        
        mapView.mapWindow.map.addCameraListener(with: self)
        
        mapView.mapWindow.map.move(with: MMKCameraPosition(
            target: MMKPoint(latitude: 25.229762, longitude: 55.289311),
            zoom: 14,
            azimuth: 0,
            tilt: 0))
    }
    
    func submitQuery() {
        let responseHandler = {(searchResponse: MMKSearchResponse?, error: Error?) -> Void in
            if let response = searchResponse {
                self.onSearchResponse(response)
            } else {
                self.onSearchError(error!)
            }
        }
        
        searchSession = searchManager!.submit(
            withText: searchEdit.text!,
            geometry: MMKVisibleRegionUtils.toPolygon(with: mapView.mapWindow.map.visibleRegion),
            searchOptions: MMKSearchOptions(),
            responseHandler: responseHandler)
    }
    
    func onCameraPositionChanged(with map: MMKMap,
                                 cameraPosition: MMKCameraPosition,
                                 cameraUpdateReason: MMKCameraUpdateReason,
                                 finished: Bool) {
        if finished {
            submitQuery()
        }
    }
    
    func onSearchResponse(_ response: MMKSearchResponse) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        mapObjects.clear()
        for searchResult in response.collection.children {
            if let point = searchResult.obj?.geometry.first?.point {
                let placemark = mapObjects.addPlacemark(with: point)
                placemark.setIconWith(UIImage(named: "SearchResult")!)
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

    @IBAction func editingChanged(_ sender: UITextField) {
        submitQuery()
    }
}
