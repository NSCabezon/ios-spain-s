//
//  CountriesRepositoryProtocol.swift
//  Commons
//
//  Created by alvola on 19/03/2020.
//



public protocol CountriesRepositoryProtocol {
    func getCountries() -> CountriesDTO?
    func load(baseUrl: String, publicLanguage: PublicLanguage)
}
