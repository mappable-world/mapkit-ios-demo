import UIKit
import MappableMobile

/**
 * This example shows how to build routes between two points and display them on the map.
 * Note: Routing API calls count towards MapKit daily usage limits.
 */
class DrivingViewController: BaseMapViewController {

    var drivingSession: MMKDrivingSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapWindow.map.move(
            with: MMKCameraPosition(target: Const.targetLocation, zoom: 6, azimuth: 0, tilt: 0))

        let requestPoints : [MMKRequestPoint] = [
            MMKRequestPoint(
                point: Const.routeStartPoint, type: .waypoint,
                pointContext: nil, drivingArrivalPointId: nil),
            MMKRequestPoint(
                point: Const.routeEndPoint, type: .waypoint,
                pointContext: nil, drivingArrivalPointId: nil),
            ]

        let responseHandler = {(routesResponse: [MMKDrivingRoute]?, error: Error?) -> Void in
            if let routes = routesResponse {
                self.onRoutesReceived(routes)
            } else {
                self.onRoutesError(error!)
            }
        }

        let drivingRouter = MMKDirections.sharedInstance().createDrivingRouter(withType: .combined)
        drivingSession = drivingRouter.requestRoutes(
            with: requestPoints,
            drivingOptions: MMKDrivingOptions(),
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
