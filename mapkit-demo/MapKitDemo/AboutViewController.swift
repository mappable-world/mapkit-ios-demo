import Foundation
import MappableMobile

class AboutViewController : UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text += MMKMapKit.sharedInstance().version
    }
}
