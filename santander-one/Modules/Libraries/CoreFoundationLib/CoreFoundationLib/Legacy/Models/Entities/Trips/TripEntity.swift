////
////  TripEntity.swift
////  Models
////
////  Created by alvola on 16/03/2020.
////

import CoreDomain

public final class TripEntity: Codable {
    public let country: CountryEntity
    public let fromDate: Date
    public let toDate: Date
    public let currencies: String
    public let tripReason: TripReason
    
    public init(country: CountryEntity,
                fromDate: Date,
                toDate: Date,
                currencies: String,
                tripReason: TripReason) {
        self.country = country
        self.fromDate = fromDate
        self.toDate = toDate
        self.currencies = currencies
        self.tripReason = tripReason
    }
    
    public var description: String {
        return "UserTripsDTO {" +
            ", country = \(country)" +
            ", fromDate= \(fromDate)" +
            ", toDate= \(toDate)" +
            ", currencies= \(currencies)" +
        ", tripReason= \(tripReason)}"
    }
}

extension TripEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.fromDate)
        hasher.combine(self.toDate)
        hasher.combine(self.country.code)
        hasher.combine(self.currencies)
        hasher.combine(self.tripReason)
     }
}

extension TripEntity: Equatable {
    public static func == (lhs: TripEntity, rhs: TripEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension TripEntity: TripRepresentable {
    public var tripCountry: CountryRepresentable {
        return country
    }
}
