import UIKit
import Foundation
import MappableMobile

extension UIColor {
    convenience init(rgbValue: UInt) {
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1
        )
    }
}

/**
 * This example shows how to build public transport routes between two points,
 * and how to handle route sections and vehicle types lists
 * Note: Masstransit routing API calls count towards MapKit daily usage limits.
 */
class MasstransitRoutingViewController: BaseMapViewController {

    var masstransitSession: MMKMasstransitSession?
    
    let ROUTE_START_POINT = MMKPoint(latitude: 25.217344, longitude: 55.361048)
    let ROUTE_END_POINT = MMKPoint(latitude: 25.210210, longitude: 55.266554)
    let TARGET_LOCATION = MMKPoint(latitude: 25.229762, longitude: 55.289311)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapWindow.map.move(
            with: MMKCameraPosition(target: TARGET_LOCATION, zoom: 11, azimuth: 0, tilt: 0))
        
        let requestPoints : [MMKRequestPoint] = [
            MMKRequestPoint(point: ROUTE_START_POINT, type: .waypoint, pointContext: nil),
            MMKRequestPoint(point: ROUTE_END_POINT, type: .waypoint, pointContext: nil),
            ]
                
        let responseHandler = {(routesResponse: [MMKMasstransitRoute]?, error: Error?) -> Void in
            if let routes = routesResponse {
                self.onRoutesReceived(routes)
            } else {
                self.onRoutesError(error!)
            }
        }


        
        let masstransitRouter = MMKTransport.sharedInstance().createMasstransitRouter()
        masstransitSession = masstransitRouter.requestRoutes(with: requestPoints, transitOptions: MMKTransitOptions(), routeHandler: responseHandler)
    }
    
    func onRoutesReceived(_ routes: [MMKMasstransitRoute]) {
        // In this example we consider first alternative only
        if (routes.count > 0) {
            for section in routes[0].sections {
                drawSection(
                    data: section.metadata.data,
                    geometry: MMKMakeSubpolyline(
                        routes[0].geometry, section.geometry));
            }
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
    
    func drawSection(data: MMKMasstransitSectionMetadataSectionData,
                     geometry : MMKPolyline) {
        // Draw a section polyline on a map
        // Set its color depending on the information which the section contains
        let mapObjects = mapView.mapWindow.map.mapObjects
        let polylineMapObject = mapObjects.addPolyline(with: geometry);
        // Masstransit route section defines exactly one on the following
        // 1. Wait until public transport unit arrives
        // 2. Walk
        // 3. Transfer to a nearby stop (typically transfer to a connected
        //    underground station)
        // 4. Ride on a public transport
        // Check the corresponding object for null to get to know which
        // kind of section it is
        if let transports = data.transports {
            // A ride on a public transport section contains information about
            // all known public transport lines which can be used to travel from
            // the start of the section to the end of the section without transfers
            // along a similar geometry
            for transport in transports  {
                // Some public transport lines may have a color associated with them
                // Typically this is the case of underground lines
                if let style = transport.line.style {
                    if let color = style.color {
                        polylineMapObject.setStrokeColorWith(UIColor(rgbValue: color.uintValue));
                        return;
                    }
                }
            }
            // Let us draw bus lines in green and tramway lines in red
            // Draw any other public transport lines in blue
            let knownVehicleTypes: Set = ["bus", "tramway"];
            for transport in transports {
                let sectionVehicleType = getVehicleType(transport: transport, knownVehicleTypes: knownVehicleTypes);
                if sectionVehicleType == "bus" {
                    polylineMapObject.setStrokeColorWith(UIColor.green);
                    return;
                } else if sectionVehicleType == "tramway" {
                    polylineMapObject.setStrokeColorWith(UIColor.red);
                    return;
                }
            }
            polylineMapObject.setStrokeColorWith(UIColor.blue);
        } else {
            // This is not a public transport ride section
            // In this example let us draw it in black
            polylineMapObject.setStrokeColorWith(UIColor.black);
        }
    }

    func getVehicleType(transport: MMKMasstransitTransport, knownVehicleTypes: Set<String> ) -> String? {
        // A public transport line may have a few 'vehicle types' associated with it
        // These vehicle types are sorted from more specific (say, 'histroic_tram')
        // to more common (say, 'tramway').
        // Your application does not know the list of all vehicle types that occur in the data
        // (because this list is expanding over time), therefore to get the vehicle type of
        // a public line you should iterate from the more specific ones to more common ones
        // until you get a vehicle type which you can process
        // Some examples of vehicle types:
        // "bus", "minibus", "trolleybus", "tramway", "underground", "railway"
        for type in transport.line.vehicleTypes {
            if knownVehicleTypes.contains(type) {
                return type;
            }
        }
        return nil;
    }
}
