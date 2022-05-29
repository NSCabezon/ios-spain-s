//
//  GetCountriesUseCase.swift
//  PersonalArea
//
//  Created by alvola on 19/03/2020.
//

import CoreFoundationLib

final class GetCountriesUseCase: UseCase<Void, GetCountriesUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCountriesUseCaseOutput, StringErrorOutput> {
        let countriesRepository: CountriesRepositoryProtocol = self.dependenciesResolver.resolve(for: CountriesRepositoryProtocol.self)
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let languageType = appRepository.getCurrentLanguage()
        countriesRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        
        guard let countriesList = countriesRepository.getCountries()?.countriesTravel, !countriesList.isEmpty else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(GetCountriesUseCaseOutput(countries: countriesList.map(CountryEntity.init)))
    }
}

struct GetCountriesUseCaseOutput {
    public let countries: [CountryEntity]
}
