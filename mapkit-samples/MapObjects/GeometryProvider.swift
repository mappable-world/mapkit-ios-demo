//
//  GeometryProvider.swift
//  MapObjects
//

import MappableMobile

enum GeometryProvider {
    static let clusterRadius: CGFloat = 60.0
    static let clusterMinZoom: UInt = 15

    static let startPoint = MMKPoint(latitude: 25.194113, longitude: 55.274531)
    static let startPosition = MMKCameraPosition(target: startPoint, zoom: 14.0, azimuth: .zero, tilt: .zero)

    static let compositeIconPoint = MMKPoint(latitude: 25.188413, longitude: 55.282270)
    static let animatedImagePoint = MMKPoint(latitude: 25.185632, longitude: 55.280006)

    static var circleWithRandomRadius: MMKCircle {
        MMKCircle(center: MMKPoint(latitude: 25.209252, longitude: 55.282737), radius: Float.random(in: 300...1000))
    }

    static let polygon: MMKPolygon = {
        var points = [
            (25.190614, 55.265616),
            (25.187532, 55.275413),
            (25.196605, 55.280940),
            (25.198219, 55.272685)
        ]
        .map { MMKPoint(latitude: $0.0, longitude: $0.1) }

        points.append(points[0])
        let outerRing = MMKLinearRing(points: points)

        let innerRing = MMKLinearRing(
            points: [
                (25.190978, 55.273982),
                (25.191958, 55.273780),
                (25.192516, 55.272040),
                (25.192015, 55.271365),
                (25.190978, 55.273982)
            ]
            .map { MMKPoint(latitude: $0.0, longitude: $0.1) }
        )

        return MMKPolygon(outerRing: outerRing, innerRings: [innerRing])
    }()

    static let polyline: MMKPolyline = {
        MMKPolyline(
            points: [
                (25.184844, 55.258163),
                (25.188887, 55.261771),
                (25.190809, 55.259483),
                (25.204718, 55.270949),
                (25.195031, 55.289207)
            ]
            .map { MMKPoint(latitude: $0.0, longitude: $0.1) }
        )
    }()

    static let clusterizedPoints = [
        (25.190614, 55.265616),
        (25.187532, 55.275413),
        (25.196605, 55.280940),
        (25.198219, 55.272685),
        (25.180998, 55.255508),
        (25.179091, 55.258284),
        (25.178095, 55.255314),
        (25.169084, 55.273855),
        (25.172865, 55.275724),
        (25.165051, 55.275517),
        (25.170596, 55.279671),
        (25.178446, 55.244884),
        (25.177345, 55.243418),
        (25.176301, 55.242463),
        (25.177808, 55.240233),
        (25.181345, 55.242272),
        (25.182055, 55.241091),
        (25.184258, 55.241001),
        (25.176576, 55.260324),
        (25.176725, 55.262622),
        (25.174783, 55.260433),
        (25.174982, 55.263005)
    ]
    .map { MMKPoint(latitude: $0.0, longitude: $0.1) }
}
