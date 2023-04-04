import UIKit
import Foundation
import MappableMobile


class BaseMapViewController : UIViewController {
    
    @IBOutlet weak var baseMapView: BaseMapView!
    
    var mapView: MMKMapView! {
        get {
            return baseMapView.mapView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
