//
//  RemoveTripUseCase.swift
//  PersonalArea
//
//  Created by alvola on 17/03/2020.
//

import CoreFoundationLib

final class RemoveTripUseCase: UseCase<RemoveTripUseCaseInput, RemoveTripUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: RemoveTripUseCaseInput) throws -> UseCaseResponse<RemoveTripUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let appRepositoryProtocol: AppRepositoryProtocol =
            self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let userPref = globalPosition.userPref  else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let trips = globalPosition.userPref?.getTrips() ?? []
        let filteredTrips = trips.filter { $0 != requestValues.trip }
        
        userPref.setTrips(filteredTrips)
        appRepositoryProtocol.setUserPreferences(userPref: userPref.userPrefDTOEntity)
        
        return UseCaseResponse.ok(RemoveTripUseCaseOkOutput(trips: filteredTrips))
    }
}

struct RemoveTripUseCaseInput {
    let trip: TripEntity
}

struct RemoveTripUseCaseOkOutput {
    let trips: [TripEntity]
}
