import UIKit
import MappableMobile

/**
 * This example shows how to build routes between two points and display them on the map.
 * Note: Routing API calls count towards MapKit daily usage limits.
 */
class DrivingViewController: BaseMapViewController {

    var drivingSession: MMKDrivingSession?
    
    let ROUTE_START_POINT = MMKPoint(latitude: 24.925953, longitude: 55.003317)
    let ROUTE_END_POINT = MMKPoint(latitude: 25.101977, longitude: 55.155337)
    let CAMERA_TARGET = MMKPoint(latitude: 25.013965, longitude: 55.079327)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapWindow.map.move(
            with: MMKCameraPosition(target: CAMERA_TARGET, zoom: 10, azimuth: 0, tilt: 0))
        
        let requestPoints : [MMKRequestPoint] = [
            MMKRequestPoint(point: ROUTE_START_POINT, type: .waypoint, pointContext: nil),
            MMKRequestPoint(point: ROUTE_END_POINT, type: .waypoint, pointContext: nil),
            ]
        
        let responseHandler = {(routesResponse: [MMKDrivingRoute]?, error: Error?) -> Void in
            if let routes = routesResponse {
                self.onRoutesReceived(routes)
            } else {
                self.onRoutesError(error!)
            }
        }
        
        let drivingRouter = MMKDirections.sharedInstance().createDrivingRouter()
        drivingSession = drivingRouter.requestRoutes(
            with: requestPoints,
            drivingOptions: MMKDrivingDrivingOptions(),
            vehicleOptions: MMKDrivingVehicleOptions(),
            routeHandler: responseHandler)
    }
    
    func onRoutesReceived(_ routes: [MMKDrivingRoute]) {
        let mapObjects = mapView.mapWindow.map.mapObjects
        for route in routes {
            mapObjects.addPolyline(with: route.geometry)
        }
    }
    
    func onRoutesError(_ error: Error) {
        let routingError = (error as NSError).userInfo[MRTUnderlyingErrorKey] as! MRTError
        var errorMessage = "Unknown error"
        if routingError.isKind(of: MRTNetworkError.self) {
            errorMessage = "Network error"
        } else if routingError.isKind(of: MRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
