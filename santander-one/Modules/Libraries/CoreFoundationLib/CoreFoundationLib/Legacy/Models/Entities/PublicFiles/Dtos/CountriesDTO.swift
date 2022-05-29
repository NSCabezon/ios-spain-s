//
//  CountriesDTO.swift
//  Models
//
//  Created by alvola on 19/03/2020.
//

public struct CountriesDTO: Codable {
    public let countriesTravel: [CountryDTO]?

    public init(countriesTravel: [CountryDTO]?) {
        self.countriesTravel = countriesTravel
    }
}
