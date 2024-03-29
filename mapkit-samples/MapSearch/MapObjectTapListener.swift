//
//  MapObjectTapListener.swift
//  MapSearch
//

import UIKit
import MappableMobile

class MapObjectTapListener: NSObject, MMKMapObjectTapListener {
    // MARK: - Constructor

    init(controller: UIViewController) {
        self.controller = controller
    }
    // MARK: - Public methods

    func onMapObjectTap(with mapObject: MMKMapObject, point: MMKPoint) -> Bool {
        guard let geoObject = mapObject.userData as? MMKGeoObject else {
            return true
        }

        let type: GeoObjectType

        if let toponym = (
            geoObject.metadataContainer
                .getItemOf(MMKSearchToponymObjectMetadata.self) as? MMKSearchToponymObjectMetadata
        ) {
            type = .toponym(
                address: toponym.address.formattedAddress
            )
        } else if let business = (
            geoObject.metadataContainer
                .getItemOf(MMKSearchBusinessObjectMetadata.self) as? MMKSearchBusinessObjectMetadata
        ) {
            type = .business(
                name: business.name,
                workingHours: business.workingHours?.text,
                categories: business.categories.map { $0.name }.joined(separator: ", "),
                phones: business.phones.map { $0.formattedNumber }.joined(separator: ", "),
                link: business.links.first?.link.href
            )
        } else {
            type = .undefined
        }

        let title = geoObject.name ?? "Unnamed"
        let description = geoObject.descriptionText ?? "No description"
        let location = geoObject.geometry.first?.point
        let uri = (
            geoObject.metadataContainer.getItemOf(MMKUriObjectMetadata.self) as? MMKUriObjectMetadata
        )?.uris.first?.value

        var message = description + "\n"
        if let location = location {
            message += "Location: (\(location.latitude), \(location.longitude))" + "\n"
        }
        if let uri = uri {
            message += "URI: \(uri)" + "\n"
        }
        switch type {
        case .toponym(let address):
            message += """
            Type: Toponym
            Address: \(address)
            """
        case let .business(name, workingHours, categories, phones, link):
            message += """
            Type: Business
            Name: \(name)
            Working hours: \(workingHours ?? "No info")
            Categories: \(categories ?? "No info")
            Phones: \(phones ?? "No info")
            Link: \(link ?? "No info")
            """
        case .undefined:
            message += "Undefined type"
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))

        controller?.present(alert, animated: true)

        return true
    }

    // MARK: - Private properties

    private weak var controller: UIViewController?

    // MARK: - Private nesting

    enum GeoObjectType {
        case toponym(address: String)

        case business(
                name: String,
                workingHours: String?,
                categories: String?,
                phones: String?,
                link: String?
             )

        case undefined
    }
}
