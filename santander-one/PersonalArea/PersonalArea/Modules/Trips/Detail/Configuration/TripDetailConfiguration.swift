//
//  TripDetailConfiguration.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 23/03/2020.
//

import CoreFoundationLib

public final class TripDetailConfiguration {
    let selectedTrip: TripEntity
    let selectedCountry: CountryEntity
    
    public init(selectedTrip: TripEntity, selectedCountry: CountryEntity) {
        self.selectedTrip = selectedTrip
        self.selectedCountry = selectedCountry
    }
}
