import XCTest
import CoreFoundationLib
import CoreTestData
@testable import Cards

final class LocationPermissionTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    private var spyLocationSettings = SpyLocationPermissionSettings()
    private var spyLocationManager = SpyLocationPermissionsManager()
    private lazy var locationPermission = {
        LocationPermission(dependenciesResolver: dependenciesResolver)
    }()
    
    override func setUp() {
        super.setUp()
        self.setupCommonsDependencies()
    }
    
    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
        self.locationPermission = LocationPermission(dependenciesResolver: dependenciesResolver)
    }
    
    func test_locationPermission_when_userLocation_is_enabled() {
        self.dependenciesResolver.register(for: LocationPermissionsManagerProtocol.self) { _ in
            let spyLocationManager = SpyLocationPermissionsManager()
            spyLocationManager.authorizationStatus = .authorizedAlways
            return spyLocationManager
        }
        
        XCTAssert(self.locationPermission.isLocationAccessEnabled())
    }
    
    func test_locationPermission_when_userLocation_is_disabled() {
        self.dependenciesResolver.register(for: LocationPermissionsManagerProtocol.self) { _ in
            let spyLocationManager = SpyLocationPermissionsManager()
            spyLocationManager.authorizationStatus = .denied
            return spyLocationManager
        }
        XCTAssertFalse(self.locationPermission.isLocationAccessEnabled())
    }
    
    func test_locationPermission_firs_time_asking_for_userLocation() {
        let spyLocationManager = SpyLocationPermissionsManager()
        spyLocationManager.authorizationStatus = .notDetermined
        self.dependenciesResolver.register(for: LocationPermissionsManagerProtocol.self) { _ in
             return spyLocationManager
        }
        XCTAssertFalse(spyLocationManager.isAlreadySet)
        XCTAssertFalse(self.locationPermission.isLocationAccessEnabled())
        self.locationPermission.setLocationPermissions({
            XCTAssertTrue(spyLocationManager.isAlreadySet)
            XCTAssertTrue(spyLocationManager.firsTimeAskingForLocation)
        })
    }
    
    func test_locationPermission_goToSettings_when_userlocation_is_already_asked_for_it_before() {
        self.dependenciesResolver.register(for: LocationPermissionSettingsProtocol.self) { _ in
            return self.spyLocationSettings
        }
        self.dependenciesResolver.register(for: LocationPermissionsManagerProtocol.self) { _ in
            let manager = SpyLocationPermissionsManager()
            manager.setGlobalLocationAsked()
            return manager
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.locationPermission.setLocationPermissions({
                XCTAssertFalse(self.spyLocationManager.firsTimeAskingForLocation)
                XCTAssertTrue(self.spyLocationSettings.successGotoSettings)
            })
        }
    }
    
    func test_locationPermission_get_location_status() {
        let locationStatus: LocationStatus = self.spyLocationManager.locationServicesStatus()
        
        XCTAssert(locationStatus == LocationStatus.authorized)
    }
    
    func test_locationPermission_get_current_location() {
        self.spyLocationManager.getCurrentLocation { latitude, longitude in
            
        }
        XCTAssert(true)
    }
    
    func test_locationPermission_goToSettings() {
        self.spyLocationSettings.goToSettings(acceptTitle: LocalizedStylableText(text: "accept_title", styles: []),
                                              cancelTitle: LocalizedStylableText(text: "cancel_title", styles: []),
                                              title: LocalizedStylableText(text: "title", styles: []),
                                              body: LocalizedStylableText(text: "body", styles: [])) {
            
        }
        XCTAssert(true)
    }
}

extension LocationPermissionTest: RegisterCommonDependenciesProtocol { }
