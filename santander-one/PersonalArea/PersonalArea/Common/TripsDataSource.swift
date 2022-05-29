//
//  TripsDataSource.swift
//  PersonalArea
//
//  Created by alvola on 14/08/2020.
//

import CoreFoundationLib

protocol TripsDataSourceProtocol {
    func hasAvailableTrips(_ completion: @escaping (Bool) -> Void)
    func getCountries(_ success: @escaping ([CountryEntity]) -> Void, failure: @escaping () -> Void)
    func getCurrentTrips(countries: [CountryEntity], completion: @escaping ([TripEntity]?) -> Void)
    func setNewTrip(_ trip: TripEntity, _ completion: @escaping (_ completed: Bool) -> Void)
    func removeTrip(_ trip: TripEntity, _ completion: @escaping ([TripEntity]?) -> Void)
    func getSafetyTips( _ completion: @escaping (GetSecurityTravelTipsUseOutput?) -> Void)
    func getEmergencyInfo(_ completion: @escaping (GetContactPhonesUseCaseOutput?) -> Void)
}

final class TripsDataSource: TripsDataSourceProtocol {
    private var dependenciesEngine: DependenciesDefault
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesEngine.resolve(for: UseCaseHandler.self)
    }
    
    init(dependenciesEngine: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesEngine)
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: GetCountriesUseCase.self) {
            return GetCountriesUseCase(dependenciesResolver: $0)
        }
        self.dependenciesEngine.register(for: GetCurrentTripsUseCase.self) {
            return GetCurrentTripsUseCase(dependenciesResolver: $0)
        }
        self.dependenciesEngine.register(for: SetNewTripUseCase.self) { _ in
            return SetNewTripUseCase()
        }
        self.dependenciesEngine.register(for: RemoveTripUseCase.self) {
            return RemoveTripUseCase(dependenciesResolver: $0)
        }
        self.dependenciesEngine.register(for: GetSecurityTravelTipsUseCase.self) {
            return GetSecurityTravelTipsUseCase(dependenciesResolver: $0)
        }
        self.dependenciesEngine.register(for: GetContactPhonesUseCaseProtocol.self) {
            return GetContactPhonesUseCase(dependenciesResolver: $0)
        }
        self.dependenciesEngine.register(for: GetContactPhonesUseCase.self) {
            return GetContactPhonesUseCase(dependenciesResolver: $0)
        }
    }
    
    func getCurrentTrips(countries: [CountryEntity], completion: @escaping ([TripEntity]?) -> Void) {
        let input = GetCurrentTripsUseCaseInput(countries: countries)
        let useCase: GetCurrentTripsUseCase = self.dependenciesEngine.resolve(for: GetCurrentTripsUseCase.self)
        
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: input),
                       useCaseHandler: useCaseHandler,
                       onSuccess: {
                        completion($0.trips)
        })
    }
    
    func setNewTrip(_ trip: TripEntity, _ completion: @escaping (_ completed: Bool) -> Void) {
        let input = SetNewTripUseCaseInput(dependenciesResolver: self.dependenciesEngine,
                                           trip: trip)
        let useCase: SetNewTripUseCase = self.dependenciesEngine.resolve(for: SetNewTripUseCase.self)
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: input),
                       useCaseHandler: useCaseHandler,
                       onSuccess: { setNewTriopOutput in
                        completion(setNewTriopOutput.completed)
        })
    }
    
    func hasAvailableTrips(_ completion: @escaping (Bool) -> Void) {
        getCountries({ [weak self] countries in
            self?.getCurrentTrips(countries: countries) { completion(!($0 ?? []).isEmpty) } },
                     failure: {
                        completion(false)
        })
    }
    
    func getCountries(_ success: @escaping ([CountryEntity]) -> Void, failure: @escaping () -> Void) {
        let useCase: GetCountriesUseCase = self.dependenciesEngine.resolve(for: GetCountriesUseCase.self)
        
        UseCaseWrapper(with: useCase,
                       useCaseHandler: useCaseHandler,
                       onSuccess: {
                        success($0.countries)
        },
                       onError: { _ in
                        failure()
        })
    }
    
    func removeTrip(_ trip: TripEntity, _ completion: @escaping ([TripEntity]?) -> Void) {
        let input = RemoveTripUseCaseInput(trip: trip)
        let useCase = self.dependenciesEngine.resolve(for: RemoveTripUseCase.self)
        UseCaseWrapper(
            with: useCase.setRequestValues(requestValues: input),
            useCaseHandler: useCaseHandler,
            onSuccess: { response in
                completion(response.trips)
        })
    }
    
    func getSafetyTips(_ completion: @escaping (GetSecurityTravelTipsUseOutput?) -> Void) {
        let useCase = self.dependenciesEngine.resolve(for: GetSecurityTravelTipsUseCase.self)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result)
            }, onError: { _ in
                completion(nil)
        })
    }
    
    func getEmergencyInfo(_ completion: @escaping (GetContactPhonesUseCaseOutput?) -> Void) {
        let useCase = self.dependenciesEngine.resolve(for: GetContactPhonesUseCase.self)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result)
        })
    }
}
