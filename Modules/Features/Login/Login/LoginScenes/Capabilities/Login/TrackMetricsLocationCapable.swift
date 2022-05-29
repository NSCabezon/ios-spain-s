//
//  LoginTrackMetricsLocationCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/2/20.
//

import Foundation
import CoreFoundationLib

protocol TrackMetricsLocationCapable: class {
    var dependenciesResolver: DependenciesResolver { get }
    func trackUserLocation(parameters: [TrackerDimension: String])
}

extension TrackMetricsLocationCapable {
    private var locationPermission: LocationPermission {
        return self.dependenciesResolver.resolve(for: LocationPermission.self)
    }
    func trackMetricsLocation() {
        guard locationPermission.isLocationAccessEnabled() else {
            self.trackUserLocation(parameters: [
                TrackerDimension.latitude: "",
                TrackerDimension.longitude: ""
            ])
            return
        }
        locationPermission.getCurrentLocation { [weak self] (latitude, longitude) in
            self?.trackUserLocation(parameters: [
                TrackerDimension.latitude: "\(latitude ?? 0)",
                TrackerDimension.longitude: "\(longitude ?? 0)"
            ])
        }
    }
}
