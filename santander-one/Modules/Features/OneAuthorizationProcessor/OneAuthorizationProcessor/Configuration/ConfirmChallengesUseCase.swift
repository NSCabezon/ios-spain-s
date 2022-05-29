//
//  ConfirmChallengesUseCase.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 4/10/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol ConfirmChallengesUseCase: UseCase<ConfirmChallengesUseCaseInput, Void, StringErrorOutput> {}

final class DefaultConfirmChallengesUseCase: UseCase<ConfirmChallengesUseCaseInput, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: ConfirmChallengesUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let repository = dependenciesResolver.resolve(for: OneAuthorizationProcessorRepository.self)
        let result = try repository.confirmChallenges(authorizationId: requestValues.authorizationId, verification: requestValues.verifications)
        switch result {
        case .success:
            return .ok()
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

extension DefaultConfirmChallengesUseCase: ConfirmChallengesUseCase {}

struct ConfirmChallengesUseCaseInput {
    let authorizationId: String
    let verifications: [ChallengeVerificationRepresentable]
}
