import UIKit
import MappableMobile

/**
 * This example shows how to add simple objects such as polygons, circles and polylines to the map.
 * It also shows how to display images instead.
 */
class MapObjectsViewController: BaseMapViewController {
    
    let CAMERA_TARGET = MMKPoint(latitude: 25.229, longitude: 55.289)
    let ANIMATED_RECTANGLE_CENTER = MMKPoint(latitude: 25.234, longitude: 55.294)
    let TRIANGLE_CENTER = MMKPoint(latitude: 25.224, longitude: 55.284)
    let POLYLINE_CENTER = MMKPoint(latitude: 25.229, longitude: 55.289)
    let CIRCLE_CENTER = MMKPoint(latitude: 25.235, longitude: 55.289)
    let DRAGGABLE_PLACEMARK_CENTER = MMKPoint(latitude: 25.224, longitude: 55.289)
    let ANIMATED_PLACEMARK_CENTER = MMKPoint(latitude: 25.229, longitude: 55.300)
    let OBJECT_SIZE: Double = 0.0015

    private var animationIsActive = true
    private var circleMapObjectTapListener: MMKMapObjectTapListener!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMapObjects()
        mapView.mapWindow.map.move(
            with: MMKCameraPosition.init(target: CAMERA_TARGET, zoom: 15, azimuth: 0, tilt: 0))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.animationIsActive = false
    }
    
    func createMapObjects() {
        let mapObjects = mapView.mapWindow.map.mapObjects
        let animatedPolygonPoints = [
            MMKPoint(
                latitude: ANIMATED_RECTANGLE_CENTER.latitude - OBJECT_SIZE,
                longitude: ANIMATED_RECTANGLE_CENTER.longitude - OBJECT_SIZE),
            MMKPoint(
                latitude: ANIMATED_RECTANGLE_CENTER.latitude - OBJECT_SIZE,
                longitude: ANIMATED_RECTANGLE_CENTER.longitude + OBJECT_SIZE),
            MMKPoint(
                latitude: ANIMATED_RECTANGLE_CENTER.latitude + OBJECT_SIZE,
                longitude: ANIMATED_RECTANGLE_CENTER.longitude + OBJECT_SIZE),
            MMKPoint(
                latitude: ANIMATED_RECTANGLE_CENTER.latitude + OBJECT_SIZE,
                longitude: ANIMATED_RECTANGLE_CENTER.longitude - OBJECT_SIZE)
        ]
        
        let animatedRectangle = mapObjects.addPolygon(
            with: MMKPolygon(outerRing: MMKLinearRing(points: animatedPolygonPoints), innerRings: []))
        animatedRectangle.fillColor = UIColor.clear
        animatedRectangle.strokeColor = UIColor.clear
        let animatedImage = MRTAnimatedImageProviderFactory.fromFile(
            Bundle.main.path(forResource: "Animations/animation", ofType: "png")) as! MRTAnimatedImageProvider
        animatedRectangle.setAnimatedImageWithAnimatedImage(
            animatedImage, patternWidth: 32)
        
        let trianglePoints = [
            MMKPoint(
                latitude: TRIANGLE_CENTER.latitude + OBJECT_SIZE,
                longitude: TRIANGLE_CENTER.longitude - OBJECT_SIZE),
            MMKPoint(
                latitude: TRIANGLE_CENTER.latitude - OBJECT_SIZE,
                longitude: TRIANGLE_CENTER.longitude - OBJECT_SIZE),
            MMKPoint(
                latitude: TRIANGLE_CENTER.latitude,
                longitude: TRIANGLE_CENTER.longitude + OBJECT_SIZE)
        ]
        
        let triangle = mapObjects.addPolygon(
            with: MMKPolygon(outerRing: MMKLinearRing(points: trianglePoints), innerRings: []))
        triangle.fillColor = UIColor.blue
        triangle.strokeColor = UIColor.black
        triangle.strokeWidth = 1
        triangle.zIndex = 100
        
        createTappableCircle();
        
        let polylinePoints = [
            MMKPoint(
                latitude: POLYLINE_CENTER.latitude + OBJECT_SIZE,
                longitude: POLYLINE_CENTER.longitude - OBJECT_SIZE),
            MMKPoint(
                latitude: POLYLINE_CENTER.latitude - OBJECT_SIZE,
                longitude: POLYLINE_CENTER.longitude - OBJECT_SIZE),
            MMKPoint(
                latitude: POLYLINE_CENTER.latitude,
                longitude: POLYLINE_CENTER.longitude + OBJECT_SIZE)
        ]
        let polyline = mapObjects.addPolyline(with: MMKPolyline(points: polylinePoints))
        polyline.setStrokeColorWith(UIColor.black)
        polyline.zIndex = 100
        
        let coloredPolylinePoints = [
            MMKPoint(
                latitude: 25.235,
                longitude: 55.300),
            MMKPoint(
                latitude: 25.235926,
                longitude: 55.303132),
            MMKPoint(
                latitude: 25.234655,
                longitude: 55.304806),
            MMKPoint(
                latitude: 25.236162,
                longitude:  55.311372)
        ]

        let coloredPolyline = mapObjects.addPolyline(with: MMKPolyline(points: coloredPolylinePoints))
        
        // lets define colors for each polyline segment
        coloredPolyline.setPaletteColorWithColorIndex(0, color: UIColor.yellow)
        coloredPolyline.setPaletteColorWithColorIndex(1, color: UIColor.green)
        coloredPolyline.setPaletteColorWithColorIndex(2, color: UIColor.purple)
        coloredPolyline.setStrokeColorsWithColors([0, 1, 2])

        // Maximum pgradient length in screen points.
        coloredPolyline.gradientLength = 250
        coloredPolyline.strokeWidth = 15
        coloredPolyline.zIndex = 100

        let placemark = mapObjects.addPlacemark(with: DRAGGABLE_PLACEMARK_CENTER)
        placemark.opacity = 0.5
        placemark.isDraggable = true
        placemark.setIconWith(UIImage(named:"Mark")!)

        createPlacemarkMapObjectWithViewProvider();
        createAnimatedPlacemark();
    }

    private class CircleMapObjectTapListener: NSObject, MMKMapObjectTapListener {
        private weak var controller: UIViewController?

        init(controller: UIViewController) {
            self.controller = controller
        }

        func onMapObjectTap(with mapObject: MMKMapObject, point: MMKPoint) -> Bool {
            if let circle = mapObject as? MMKCircleMapObject {
                let randomRadius: Float = 100.0 + 50.0 * Float.random(in: 0..<10);
                let curGeometry = circle.geometry;
                circle.geometry = MMKCircle(center: curGeometry.center, radius: randomRadius);

                if let userData = circle.userData as? CircleMapObjectUserData {
                    let message = "Circle with id \(userData.id) and description '\(userData.description)' tapped";
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert);
                    alert.view.backgroundColor = UIColor.darkGray;
                    alert.view.alpha = 0.8;
                    alert.view.layer.cornerRadius = 15;

                    controller?.present(alert, animated: true);
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        alert.dismiss(animated: true);
                    }
                }
            }
            return true;
        }
    }

    private class CircleMapObjectUserData {
        let id: Int32;
        let description: String;
        init(id: Int32, description: String) {
            self.id = id;
            self.description = description;
        }
    }

    func createTappableCircle() {
        let mapObjects = mapView.mapWindow.map.mapObjects;
        let circle = mapObjects.addCircle(
            with: MMKCircle(center: CIRCLE_CENTER, radius: 100),
            stroke: UIColor.green,
            strokeWidth: 2,
            fill: UIColor.red)
        circle.zIndex = 100
        circle.userData = CircleMapObjectUserData(id: 42, description: "Tappable circle");

        // Client code must retain strong reference to the listener.
        circleMapObjectTapListener = CircleMapObjectTapListener(controller: self);
        circle.addTapListener(with: circleMapObjectTapListener);
    }

    func createPlacemarkMapObjectWithViewProvider() {
        let textView =
            UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 30));
        let colors = [UIColor.red, UIColor.green, UIColor.black];

        textView.isOpaque = false;
        textView.backgroundColor = UIColor.clear.withAlphaComponent(0.0);
        textView.text = "Hello, World!";
        textView.textColor = UIColor.red;

        let viewProvider = MRTViewProvider(uiView: textView);

        let mapObjects = mapView.mapWindow.map.mapObjects;
        let viewPlacemark = mapObjects.addPlacemark(
            with: MMKPoint(latitude: 25.220, longitude: 55.289),
            view: viewProvider!);

        let delayToShowInitialText = 5.0;  // seconds
        let delayToShowRandomText = 0.5; // seconds

        // Show initial text `delayToShowInitialText` seconds and then
        // randomly change text in textView every `delayToShowRandomText` seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToShowInitialText) {

            func doMainLoop() {
                if !self.animationIsActive {
                    return
                }

                let randomInt = Int(arc4random_uniform(1000));
                textView.text = "Some text " + String(randomInt);
                textView.textColor = colors[randomInt % colors.count];
                viewProvider?.snapshot();
                viewPlacemark.setViewWithView(viewProvider!);

                DispatchQueue.main.asyncAfter(deadline: .now() + delayToShowRandomText) {
                    doMainLoop()
                }
            }

            doMainLoop();
        }
    }
    
    func createAnimatedPlacemark() {
        let animatedImageProvider = MRTAnimatedImageProviderFactory.fromFile(
            Bundle.main.path(forResource: "Animations/animation", ofType: "png")) as! MRTAnimatedImageProvider
        let mapObjects = mapView.mapWindow.map.mapObjects;
        let animatedPlacemark = mapObjects.addPlacemark(with: ANIMATED_PLACEMARK_CENTER, animatedImage: animatedImageProvider, style: MMKIconStyle())
        animatedPlacemark.useAnimation().play()
    }
}
