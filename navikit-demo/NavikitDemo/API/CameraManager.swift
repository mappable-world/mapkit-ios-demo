//
//  CameraManager.swift
//

import MappableMobile

protocol CameraManager {
    // MARK: - Public properties

    var cameraMode: MMKCameraMode { get set }

    // MARK: - Public methods

    func changeZoom(_ change: ZoomChange)
    func moveCameraToUserLocation()
    func start()
}
