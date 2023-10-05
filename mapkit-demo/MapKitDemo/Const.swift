import MappableMobile

enum Const {
	static let clusterCenters: [MMKPoint] = [
		MMKPoint(latitude: 25.229, longitude: 55.289),
        MMKPoint(latitude: 24.079, longitude: 52.653),
        MMKPoint(latitude: 40.715, longitude: -74.004)
    ]

	static let targetLocation = MMKPoint(latitude: 25.229762, longitude: 55.289311)

	static let routeStartPoint = MMKPoint(latitude: 24.925953, longitude: 55.003317)
    static let routeEndPoint = MMKPoint(latitude: 25.101977, longitude: 55.155337)

    static let animatedRectangleCenter = MMKPoint(latitude: 25.229, longitude: 55.300)
    static let triangleCenter = MMKPoint(latitude: 25.224, longitude: 55.289)
    static let circleCenter = MMKPoint(latitude: 25.235, longitude: 55.289)
    static let draggablePlacemarkCenter = MMKPoint(latitude: 25.224, longitude: 55.289)
    static let animatedPlacemarkCenter = MMKPoint(latitude: 25.229, longitude: 55.300)

	static let coloredPolylinePoints = [
		MMKPoint(latitude: 25.249941, longitude: 55.310250),
		MMKPoint(latitude: 25.250867, longitude: 55.313382),
		MMKPoint(latitude: 25.249596, longitude: 55.315056),
		MMKPoint(latitude: 25.251103, longitude: 55.321622)
    ]

	static let boundingBox = MMKBoundingBox(
        southWest: MMKPoint(latitude: 25.229, longitude: 37.42),
        northEast: MMKPoint(latitude: 25.429, longitude: 55.700))

	static let logoURL = "https://raw.githubusercontent.com/MappableWorld/mapkit-android-demo/master/src/main/res/drawable/ic_launcher.png"
}