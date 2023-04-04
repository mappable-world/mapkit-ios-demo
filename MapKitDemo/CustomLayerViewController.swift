import UIKit
import MappableMobile

/**
 * This example shows how to add a user-defined layer to the map.
 * We use the UrlProvider class to format requests to a remote server that renders
 * tiles. For simplicity, we ignore map coordinates and zoom here, and
 * just provide a URL for the static image.
 */
class CustomLayerViewController: BaseMapViewController {
    
    var layer: MMKLayer?

    internal class CustomTilesUrlProvider: NSObject, MMKTilesUrlProvider {
        func formatUrl(with tileId: MMKTileId, version: MMKVersion) -> String {
            return "https://raw.githubusercontent.com/MappableWorld/mapkit-android-demo/master/src/main/res/drawable/ic_launcher.png"
        }
    }

    // MapKit  doesn't need Url provider for raster maps.
    internal class DummyUrlProvider : NSObject, MMKResourceUrlProvider {
        override init() {}

        func formatUrl(withResourceId resourceId: String) -> String {
            return "";
        }

        override func isEqual(_ object: Any?) -> Bool {
            return true;
        }
    }

    // Client code must retain strong references to providers and projection
    let tilesUrlProvider = CustomTilesUrlProvider()
    let projection = MMKProjections.wgs84Mercator()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapWindow.map.mapType = .none

        let layerOptions = MMKLayerOptions(
            active: true,
            nightModeAvailable: true,
            cacheable: true,
            animateOnActivation: true,
            tileAppearingAnimationDuration: 0,
            overzoomMode: .enabled,
            transparent: false
        )

        layer = mapView.mapWindow.map.addLayer(
            withLayerId: "mapkit_logo",
            contentType: "image/png",
            layerOptions: layerOptions,
            tileUrlProvider: tilesUrlProvider,
            imageUrlProvider: MMKImagesDefaultUrlProvider(),
            projection: projection)

        layer!.invalidate(withVersion: "0.0.0")
    }
}
