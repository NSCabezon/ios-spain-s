//
//  CountriesRepositoryProtocolMock.swift
//  PersonalArea
//
//  Created by Juan Jose Acosta González on 10/9/21.
//

import CoreFoundationLib

final class CountriesRepositoryProtocolMock: CountriesRepositoryProtocol {
    func load(baseUrl: String, publicLanguage: PublicLanguage) {
    }
    
    func getCountries() -> CountriesDTO? {
        return nil
    }
}
