//
//  ClusterListener.swift
//  MapObjects
//

import MappableMobile

final class ClusterListener: NSObject, MMKClusterListener, MMKClusterTapListener {
    // MARK: - Constructor

    init(controller: UIViewController) {
        self.controller = controller
    }

    // MARK: - Public methods

    func onClusterTap(with cluster: MMKCluster) -> Bool {
        AlertPresenter.present(
            from: controller,
            with: "Tapped the cluster",
            message: "With \(cluster.size) items"
        )
        return true
    }

    func onClusterAdded(with cluster: MMKCluster) {
        let placemarks = cluster.placemarks.compactMap { $0.userData as? PlacemarkUserData }
        cluster.appearance.setViewWithView(MRTViewProvider(uiView: ClusterView(placemarks: placemarks)))
        cluster.addClusterTapListener(with: self)
    }

    // MARK: - Private properties

    private weak var controller: UIViewController?
}
