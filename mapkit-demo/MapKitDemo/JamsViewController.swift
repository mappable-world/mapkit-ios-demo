import UIKit
import MappableMobile

/**
 * This example shows how to add layer traffic on the map.
 */
class JamsViewController: BaseMapViewController, MMKMapCameraListener, MMKTrafficDelegate {

    @IBOutlet weak var trafficButton: UISwitch!
    @IBOutlet weak var trafficLabel: UILabel!
    var trafficLayer : MMKTrafficLayer!
    override func viewDidLoad() {
        super.viewDidLoad()

        trafficLayer = MMKMapKit.sharedInstance().createTrafficLayer(with: mapView.mapWindow)
        trafficLayer.addTrafficListener(withTrafficListener: self)
        mapView.mapWindow.map.addCameraListener(with: self)

        mapView.mapWindow.map.move(with: MMKCameraPosition(
            target: Const.targetLocation,
            zoom: 14,
            azimuth: 0,
            tilt: 0))

        onSwitchTraffic(self)
    }

    func onCameraPositionChanged(with map: MMKMap,
                                 cameraPosition: MMKCameraPosition,
                                 cameraUpdateReason: MMKCameraUpdateReason,
                                 finished: Bool) {
    }

    @IBAction func onSwitchTraffic(_ sender: Any) {
        if trafficButton.isOn {
            trafficLabel.text = "0"
            trafficLabel.backgroundColor = UIColor.white
            trafficLayer.setTrafficVisibleWithOn(true)
        } else {
            trafficLabel.text = ""
            trafficLabel.backgroundColor = UIColor.gray
            trafficLayer.setTrafficVisibleWithOn(false)
        }
    }

    func onTrafficChanged(with trafficLevel: MMKTrafficLevel?) {
        if trafficLevel == nil {
            return
        }
        trafficLabel.text = String(trafficLevel!.level)
        switch trafficLevel!.color {
        case MMKTrafficColor.red:
            trafficLabel.backgroundColor = UIColor.red
            break
        case MMKTrafficColor.green:
            trafficLabel.backgroundColor = UIColor.green
            break
        case MMKTrafficColor.yellow:
            trafficLabel.backgroundColor = UIColor.yellow
            break
        default:
            trafficLabel.backgroundColor = UIColor.white
            break
        }
    }

    func onTrafficLoading() {

    }

    func onTrafficExpired() {

    }
}
