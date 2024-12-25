//
//  MapViewModel.swift
//

import Combine
import MappableMobile
import MMKStylingAutomotiveNavigation
import MMKStylingRoadEvents

final class MapViewModel {
    // MARK: - Public properties

    private(set) var mapWindow: MMKMapWindow!
    private(set) var map: MMKMap!

    private(set) var guidance: MMKGuidance!

    private(set) var locationManager: LocationManager!
    private(set) var navigationManager: NavigationManager!
    private(set) var simulationManager: SimulationManager!
    private(set) var navigationLayerManager: NavigationLayerManager!

    private(set) var mapViewStateManager: MapViewStateManager!

    private(set) lazy var settingsRepository = SettingsRepositoryImpl()

    private(set) lazy var cameraManager = CameraManagerImpl(
        map: map,
        camera: camera,
        locationManager: locationManager,
        settingsRepository: SettingsRepositoryImpl()
    )

    private(set) lazy var routingManager = RoutingManagerImpl(navigationManager: navigationManager)

    // MARK: - Public methods

    func setup(with mapWindow: MMKMapWindow, controller: UIViewController) {
        self.mapWindow = mapWindow
        self.controller = controller

        map = mapWindow.map
    }

    func setController(with controller: UIViewController) {
        self.controller = controller
    }

    func serializeNavigationIfNeeded() {
        if navigationManager.status.value == .started,
           settingsRepository.restoreGuidanceState.value {
            navigationManager.serializeNavigation()
        }
    }

    // MARK: - Private properties

    private var navigation: MMKNavigation!
    private var camera: MMKCamera!
    private var navigationLayer: MMKNavigationLayer!
    private var mapObjectCollection: MMKMapObjectCollection!

    private var mapSizeChangedListener: MapSizeChangedListener!
    private var mapLongTapViewModel: MapLongTapViewModel!

    private var vehicleOptionsProvider: VehicleOptionsProvider!
    private var navigationStyleManager: NavigationStyleManager = NavigationStyleManagerImpl()

    private var settingsBinder: SettingsBinder!

    private var speaker: Speaker!
    private var annotationsManager: AnnotationsManager!

    private lazy var roadEventsManager = MMKMapKit.sharedInstance().createRoadEventsManager()
    private lazy var roadEventsStyleProvider = MMKRoadEventsStyleProvider()
    private lazy var navigationStyleProvider = MMKAutomotiveNavigationStyleProvider()

    private lazy var navigationListener = NavigationListener()
    private lazy var navigationLayerListener = NavigationLayerListener()

    private lazy var alertPresenter = AlertPresenter(controller: controller)

    private lazy var annotator: MMKAnnotator = guidance.annotator

    private lazy var mockLocationManager = MMKMapKit.sharedInstance().createLocationManager()
    private lazy var mockLocationDelegate = MockLocationDelegate()

    private var cancellablesBag = Set<AnyCancellable>()

    private(set) weak var controller: UIViewController?

    private var navigationController: UINavigationController? {
        controller?.navigationController
    }

    // MARK: - Private nesting

    private class MockLocationDelegate: NSObject, MMKLocationDelegate {
        func onLocationUpdated(with location: MMKLocation) {}
        func onLocationStatusUpdated(with status: MMKLocationStatus) {}
    }
}

extension MapViewModel {
    func setup() {
        setupNavigation()
        setupModels()
        setupListeners()
        start()

        setupNightModeSubscription()

        setupBackground()
        setupSerialization()
    }

    func setupStateSubscription(onStateChanged stateChangedHandler: @escaping () -> Void) {
        mapViewStateManager.viewState
            .sink { [weak self] _ in
                self?.mapSizeChangedListener.updateFocusRect()
                stateChangedHandler()
            }
            .store(in: &cancellablesBag)
    }

    func updateColorScheme() {
        switch settingsRepository.styleMode.value {
        case .day:
            map.isNightModeEnabled = false

        case .night:
            map.isNightModeEnabled = true

        case .system:
            map.isNightModeEnabled = controller?.view!.traitCollection.userInterfaceStyle == .dark
        }
    }

    private func setupNavigation() {
        let serializedNavigation = settingsRepository.serializedNavigation.value
        guard !serializedNavigation.isEmpty,
              let serializedNavigationData = Data(base64Encoded: serializedNavigation) else {
            initializeNavigation(serializedNavigation: nil)
            return
        }
        initializeNavigation(serializedNavigation: serializedNavigationData)
    }

    private func setupModels() {
        simulationManager = SimulationManagerImpl(settingsRepository: settingsRepository)
        vehicleOptionsProvider = VehicleOptionsProviderImpl(settingsRepository: settingsRepository)
        speaker = SpeakerImpl()
        annotationsManager = AnnotationsManagerImpl(
            speaker: speaker,
            annotator: annotator,
            settingsRepository: settingsRepository,
            alertPresenter: alertPresenter
        )
        annotationsManager.start()

        navigationManager = NavigationManagerImpl(
            navigation: navigation,
            locationManager: locationManager,
            simulationManager: simulationManager,
            vehicleOptionManager: vehicleOptionsProvider,
            settingsRepository: settingsRepository
        )
        navigationManager.start()

        mapViewStateManager = MapViewStateManagerImpl(
            navigationManager: navigationManager,
            cameraManager: cameraManager
        )
        mapSizeChangedListener = MapSizeChangedListener(
            mapWindow: mapWindow,
            mapViewStateManager: mapViewStateManager
        )

        mapLongTapViewModel = MapLongTapViewModel(
            map: map,
            routingManager: routingManager,
            alertPresenter: alertPresenter,
            mapViewStateManager: mapViewStateManager
        )
        mapLongTapViewModel.setup()

        navigationLayerManager = NavigationLayerManagerImpl(
            navigationLayer: navigationLayer,
            mapViewStateManager: mapViewStateManager
        )
        navigationLayerManager.setup()

        settingsBinder = SettingsBinderImpl(
            settingsRepository: settingsRepository,
            simulationManager: simulationManager,
            navigationStyleManager: navigationStyleManager,
            navigationLayer: navigationLayer,
            navigation: navigation,
            camera: camera,
            speaker: speaker,
            annotationsManager: annotationsManager
        )
        settingsBinder.bindSettings()

        if !settingsRepository.serializedNavigation.value.isEmpty,
           settingsRepository.restoreGuidanceState.value {
            mapViewStateManager.set(state: .guidance)
            settingsRepository.serializedNavigation.send(String())
        }
    }

    private func setupListeners() {
        mapWindow.addSizeChangedListener(with: mapSizeChangedListener)
        mapSizeChangedListener.updateFocusRect()
    }

    private func start() {
        cameraManager.start()
        cameraManager.moveCameraToUserLocation()
    }

    private func setupNightModeSubscription() {
        settingsRepository.styleMode
            .sink { [weak self] _ in
                self?.updateColorScheme()
            }
            .store(in: &cancellablesBag)
    }

    private func setupBackground() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onReturnedFromBackground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func setupSerialization() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    @objc
    private func onMovedToBackground() {
        if settingsRepository.background.value {
            if simulationManager.isSimulationActive.value {
                // Subscription is just for keeping app alive in background
                mockLocationManager.subscribeForLocationUpdates(
                    with: MMKLocationSubscriptionSettings(useInBackground: .allow, purpose: .automotiveNavigation),
                    locationListener: mockLocationDelegate
                )
            }
        } else {
            navigation.suspend()

            simulationManager.suspend()
        }
    }

    @objc
    private func onReturnedFromBackground() {
        if settingsRepository.background.value {
            mockLocationManager.unsubscribe(withLocationListener: mockLocationDelegate)
        } else {
            navigation.resume()

            simulationManager.resume()
        }
    }

    @objc
    private func onWillTerminate() {
        serializeNavigationIfNeeded()
    }
}

private extension MapViewModel {
    func initializeNavigation(serializedNavigation: Data?) {
        if navigationLayer != nil {
            navigationLayer.removeFromMap()
            navigationLayer = nil
        }

        if navigation != nil {
            navigation.stopGuidance()
            navigation.resetRoutes()
            guidance.isEnableAlternatives = true

            simulationManager.stop()
            simulationManager.suspend()

            navigation.suspend()
        }

        navigation = nil
        if let serializedNavigation {
            navigation = MMKNavigationSerialization.deserialize(serializedNavigation)
        }
        if navigation == nil {
            navigation = MMKNavigationFactory.createNavigation(with: .combined)
        }

        navigation.addListener(with: navigationListener)
        guidance = navigation.guidance
        locationManager = LocationManagerImpl(guidance: guidance)
        locationManager.addGuidanceListener()

        locationManager.onLocationChanged()

        initializeNavigationLayer()

        navigation.resume()
    }

    func initializeNavigationLayer() {
        if navigationLayer != nil {
            navigationLayer.removeFromMap()
        }

        navigation.removeListener(with: navigationListener)
        locationManager.removeGuidanceListener()

        navigationLayer = MMKNavigationLayerFactory.createNavigationLayer(
            with: mapWindow,
            roadEventsLayerStyleProvider: roadEventsStyleProvider,
            styleProvider: navigationStyleManager,
            navigation: navigation
        )

        navigation.addListener(with: navigationListener)
        locationManager.addGuidanceListener()

        navigationLayer.addListener(with: navigationLayerListener)

        camera = navigationLayer.camera

        navigationLayer.refreshStyle()
    }
}
