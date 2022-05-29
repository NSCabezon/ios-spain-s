//
//  GetTripModeEnabledUseCase.swift
//  PersonalArea
//
//  Created by César González Palomino on 25/03/2020.
//

import CoreFoundationLib

final class GetTripModeEnabledUseCase: UseCase<Void, GetTripModeEnabledUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTripModeEnabledUseCaseOutput, StringErrorOutput> {
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let searchEnabled = appConfigRepository.getBool("enableTripMode") ?? false
        return UseCaseResponse.ok(GetTripModeEnabledUseCaseOutput(tripModeEnabled: searchEnabled))
    }
}

public struct GetTripModeEnabledUseCaseOutput {
    public let tripModeEnabled: Bool
}
