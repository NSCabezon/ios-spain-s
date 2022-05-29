import SANLegacyLibrary
import CoreLocation
import CoreFoundationLib

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var completionLocation: ((Double?, Double?) -> Void)?
    private var completionAskLocation: (() -> Void)?
    private var timer: Timer?
    private let keyAskedGlobalLocation = "LocationManager.askGlobalLocation"
    
    var isAlreadySet: Bool {
        return locationServicesStatus() != .notDetermined
    }
    
    deinit {
        cleanTimer()
        stopLocation()
        completionLocation = nil
    }
    
    func getCurrentLocation(completion: @escaping ((_ latitude: Double?, _ longitude: Double?) -> Void)) {
        locationManager.delegate = self
        self.completionLocation = completion
        startTimer()
        getLocation(completion: completion)
    }
    
    func askAuthorizationIfNeeded(completion: @escaping () -> Void) {
        let status = locationServicesStatus()
        switch status {
        case .authorized, .denied:
            completion()
        case .notDetermined:
            completionAskLocation = completion
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func askedGlobalLocation() {
        UserDefaults.standard.set(true, forKey: keyAskedGlobalLocation)
        UserDefaults.standard.synchronize()
    }
    
    func askGlobalLocation() -> Bool {
        if UserDefaults.standard.bool(forKey: keyAskedGlobalLocation) {
            return false
        } else {
            return true
        }
    }
    
    @objc func firedTimer() {
        finishLocation(nil, nil)
    }
    
    private func finishLocation(_ latitude: Double?, _ longitude: Double?) {
        cleanTimer()
        stopLocation()
        completionLocation?(latitude, longitude)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(firedTimer), userInfo: nil, repeats: false)
    }
    
    private func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    private func getLocation(completion: @escaping ((_ latitude: Double?, _ longitude: Double?) -> Void)) {
        let status = locationServicesStatus()
        switch status {
        case .authorized:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            } else {
                finishLocation(nil, nil)
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            finishLocation(nil, nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        completionAskLocation?()
        completionAskLocation = nil
        guard let completion = completionLocation else { return }
        getLocation(completion: completion)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = manager.location?.coordinate else { return }
        finishLocation(locValue.latitude, locValue.longitude)
    }
}

extension LocationManager: LocationPermissionsManagerProtocol {
    func isLocationAccessEnabled() -> Bool {
        return locationServicesStatus() == .authorized
    }
    
    func setGlobalLocationAsked() {
        self.askedGlobalLocation()
    }
    
    func locationServicesStatus() -> LocationStatus {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return .notDetermined
        case .restricted, .denied:
            return .denied
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        @unknown default:
            return .authorized
        }
    }
}
