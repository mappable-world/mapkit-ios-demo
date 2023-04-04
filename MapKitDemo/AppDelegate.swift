import UIKit
import MappableMobile

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    /**
     * Replace "your_api_key" with a valid developer key.
     * You can get it at the https://mappable.world/ website.
     */
    let MAPKIT_API_KEY = "your_api_key"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /**
         * Set API key before interaction with MapKit.
         */
        MMKMapKit.setApiKey(MAPKIT_API_KEY)

        /**
         * You can optionaly customize  locale.
         * Otherwise MapKit will use default location.
         */
        MMKMapKit.setLocale("en_US")
        
        /**
         * If you create instance of MMKMapKit not in application:didFinishLaunchingWithOptions: 
         * you should also explicitly call MMKMapKit.sharedInstance().onStart()
         */
        MMKMapKit.sharedInstance()

        return true
    }
}
