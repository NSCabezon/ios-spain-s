//
//  LocationUtils.swift
//  Commons
//
//  Created by Tania Castellano Brasero on 19/10/2020.
//
public struct Location {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public class LocationUtils {
    static let radiusOfEarth: Double = 6378100
    
    public static func calculateCoordinateFromCoordinate(_ coordinate: Location, onBearingInRadians bearing: Double, atDistanceInMetres distance: Double) -> Location {
        let coordinateLatitudeInRadians = coordinate.latitude * .pi / 180
        let coordinateLongitudeInRadians = coordinate.longitude * .pi / 180
        let distanceComparedToEarth = distance / self.radiusOfEarth
        let resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearing))
        let resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearing) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians))
        let latitude = resultLatitudeInRadians * 180 / .pi
        let longitude = resultLongitudeInRadians * 180 / .pi
        return Location(latitude: latitude, longitude: longitude)
    }
}
