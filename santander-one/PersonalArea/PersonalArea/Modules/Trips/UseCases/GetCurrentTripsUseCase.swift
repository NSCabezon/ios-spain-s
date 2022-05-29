//
//  GetCurrentTripsUseCase.swift
//  PersonalArea
//
//  Created by alvola on 16/03/2020.
//

import CoreFoundationLib

final class GetCurrentTripsUseCase: UseCase<GetCurrentTripsUseCaseInput, GetCurrentTripsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: GetCurrentTripsUseCaseInput) throws -> UseCaseResponse<GetCurrentTripsUseCaseOkOutput, StringErrorOutput> {
        
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let appRepositoryProtocol: AppRepositoryProtocol =
            self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let userPref = globalPosition.userPref  else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        var trips = globalPosition.userPref?.getTrips() ?? []
        trips = filterPastTrips(trips)
        trips = filterTripsWithoutValidCountry(trips, countries: requestValues.countries)
        
        userPref.setTrips(trips)
        appRepositoryProtocol.setUserPreferences(userPref: userPref.userPrefDTOEntity)
        
        return UseCaseResponse.ok(GetCurrentTripsUseCaseOkOutput(trips: trips))
    }
    
    private func filterPastTrips(_ trips: [TripEntity]) -> [TripEntity] {
        let today = Date()
        return trips.compactMap {
            Calendar.current.compare($0.toDate, to: today, toGranularity: .day) == .orderedAscending ? nil : $0
        }
    }
    
    private func filterTripsWithoutValidCountry(_ trips: [TripEntity], countries: [CountryEntity]) -> [TripEntity] {
        return trips.compactMap { trip in
            countries.contains { $0 == trip.country } ? trip : nil
        }
    }
}

struct GetCurrentTripsUseCaseInput {
    let countries: [CountryEntity]
}

struct GetCurrentTripsUseCaseOkOutput {
    let trips: [TripEntity]?
}
