//
//  SetNewTripUseCase.swift
//  PersonalArea
//
//  Created by alvola on 16/03/2020.
//

import CoreFoundationLib

final class SetNewTripUseCase: UseCase<SetNewTripUseCaseInput, SetNewTripUseCaseOkOutput, StringErrorOutput> {
    override public func executeUseCase(requestValues: SetNewTripUseCaseInput) throws -> UseCaseResponse<SetNewTripUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            requestValues.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let appRepositoryProtocol: AppRepositoryProtocol =
            requestValues.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let userPref = globalPosition.userPref else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        var trips = globalPosition.userPref?.getTrips() ?? []
        trips.append(requestValues.trip)
        userPref.setTrips(trips)
        
        appRepositoryProtocol.setUserPreferences(userPref: userPref.userPrefDTOEntity)
        
        return UseCaseResponse.ok(SetNewTripUseCaseOkOutput(completed: true))
    }
}

struct SetNewTripUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let trip: TripEntity
}

struct SetNewTripUseCaseOkOutput {
    let completed: Bool
}
