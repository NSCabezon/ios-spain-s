//
//  IsM4MactiveSuscriptionEnabledUseCase.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 11/5/21.
//

import CoreFoundationLib
import SANLegacyLibrary

typealias IsM4MactiveSuscriptionEnabledUseCaseAlias = UseCase<Void, IsM4MactiveSuscriptionEnabledUseCaseOkOutput, StringErrorOutput>

final class IsM4MactiveSuscriptionEnabledUseCase: IsM4MactiveSuscriptionEnabledUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<IsM4MactiveSuscriptionEnabledUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isM4MactiveSuscriptionEnabled = appConfigRepository.getBool(CardConstants.isM4MactiveSuscriptionEnabled) ?? false
        return .ok(IsM4MactiveSuscriptionEnabledUseCaseOkOutput(isM4MactiveSuscriptionEnabled: isM4MactiveSuscriptionEnabled))
    }
}

struct IsM4MactiveSuscriptionEnabledUseCaseOkOutput {
    let isM4MactiveSuscriptionEnabled: Bool
}
