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
            return Const.logoURL
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
            format: MMKTileFormat.png,
            layerOptions: layerOptions,
            tileUrlProvider: tilesUrlProvider,
            imageUrlProvider: MMKImagesDefaultUrlProvider(),
            projection: projection)

        layer!.dataSourceLayer().invalidate(withVersion: "0.0.0")
    }
}
