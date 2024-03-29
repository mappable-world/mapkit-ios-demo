import Foundation
import UIKit
import MappableMobile

/**
 * This example shows how to add a collection of clusterized placemarks to the map.
 */
class ClusteringViewController : BaseMapViewController, MMKClusterListener, MMKClusterTapListener {

    private var imageProvider = UIImage(named: "SearchResult")!
    private let PLACEMARKS_NUMBER = 2000
    private let FONT_SIZE: CGFloat = 15
    private let MARGIN_SIZE: CGFloat = 3
    private let STROKE_SIZE: CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraPosition = MMKCameraPosition(
            target: Const.clusterCenters[0], zoom: 3, azimuth: 0, tilt: 0)
        mapView.mapWindow.map.move(with: cameraPosition)

        // Note that application must retain strong references to both
        // cluster listener and cluster tap listener
        let collection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)

        let points = createPoints()
        collection.addPlacemarks(with: points, image: self.imageProvider, style: MMKIconStyle())

        // Placemarks won't be displayed until this method is called. It must be also called
        // to force clusters update after collection change
        collection.clusterPlacemarks(withClusterRadius: 60, minZoom: 15)
    }

    func clusterImage(_ clusterSize: UInt) -> UIImage {
        let scale = UIScreen.main.scale
        let text = (clusterSize as NSNumber).stringValue
        let font = UIFont.systemFont(ofSize: FONT_SIZE * scale)
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        let textRadius = sqrt(size.height * size.height + size.width * size.width) / 2
        let internalRadius = textRadius + MARGIN_SIZE * scale
        let externalRadius = internalRadius + STROKE_SIZE * scale
        let iconSize = CGSize(width: externalRadius * 2, height: externalRadius * 2)

        UIGraphicsBeginImageContext(iconSize)
        let ctx = UIGraphicsGetCurrentContext()!

        ctx.setFillColor(UIColor.red.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: .zero,
            size: CGSize(width: 2 * externalRadius, height: 2 * externalRadius)));

        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(
            origin: CGPoint(x: externalRadius - internalRadius, y: externalRadius - internalRadius),
            size: CGSize(width: 2 * internalRadius, height: 2 * internalRadius)));

        (text as NSString).draw(
            in: CGRect(
                origin: CGPoint(x: externalRadius - size.width / 2, y: externalRadius - size.height / 2),
                size: size),
            withAttributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.black])
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }

    func onClusterAdded(with cluster: MMKCluster) {
        // We setup cluster appearance and tap handler in this method
        cluster.appearance.setIconWith(clusterImage(cluster.size))
        cluster.addClusterTapListener(with: self)
    }

    func onClusterTap(with cluster: MMKCluster) -> Bool {
        let alert = UIAlertController(
            title: "Tap",
            message: String(format: "Tapped cluster with %u items", cluster.size),
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)

        // We return true to notify map that the tap was handled and shouldn't be
        // propagated further.
        return true
    }

    func randomDouble() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX)
    }

    func createPoints() -> [MMKPoint]{
        var points = [MMKPoint]()
        for _ in 0..<PLACEMARKS_NUMBER {
            let clusterCenter = Const.clusterCenters.randomElement()!
            let latitude = clusterCenter.latitude + randomDouble()  - 0.5
            let longitude = clusterCenter.longitude + randomDouble()  - 0.5

            points.append(MMKPoint(latitude: latitude, longitude: longitude))
        }

        return points
    }
}
