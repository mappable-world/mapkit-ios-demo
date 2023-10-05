import UIKit
import MappableMobile

class SuggestCell: UITableViewCell {
    @IBOutlet weak var itemName: UILabel!
}

/**
 * This example shows how to request a suggest for search requests.
 */
class SuggestViewController: BaseMapViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UITextField!

    var suggestResults: [MMKSuggestItem] = []
    let searchManager = MMKSearch.sharedInstance().createSearchManager(with: .combined)
    var suggestSession: MMKSearchSuggestSession!

    let SUGGEST_OPTIONS = MMKSuggestOptions()

    override func viewDidLoad() {
        super.viewDidLoad()
        suggestSession = searchManager.createSuggestSession()
        tableView.dataSource = self
    }

    func onSuggestResponse(_ items: [MMKSuggestItem]) {
        suggestResults = items
        tableView.reloadData()
    }

    func onSuggestError(_ error: Error) {
        let suggestError = (error as NSError).userInfo[MRTUnderlyingErrorKey] as! MRTError
        var errorMessage = "Unknown error"
        if suggestError.isKind(of: MRTNetworkError.self) {
            errorMessage = "Network error"
        } else if suggestError.isKind(of: MRTRemoteError.self) {
            errorMessage = "Remote server error"
        }

        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    @IBAction func queryChanged(_ sender: UITextField) {
        let suggestHandler = {(response: [MMKSuggestItem]?, error: Error?) -> Void in
            if let resp = response {
                self.onSuggestResponse(resp)
            } else {
                self.onSuggestError(error!)
            }
        }

        suggestSession.suggest(
            withText: sender.text!,
            window: Const.boundingBox,
            suggestOptions: SUGGEST_OPTIONS,
            responseHandler: suggestHandler)
    }

    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestCell", for: path) as! SuggestCell
        cell.itemName.text = suggestResults[path.row].displayText

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestResults.count
    }
}
