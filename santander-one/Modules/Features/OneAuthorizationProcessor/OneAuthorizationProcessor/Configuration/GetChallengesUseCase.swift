//
//  GetChallengesUseCase.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 4/10/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol GetChallengesUseCase: UseCase<GetChallengesUseCaseInput, GetChallengesUseCaseOkOutput, StringErrorOutput> {}

final class DefaultGetChallengesUseCase: UseCase<GetChallengesUseCaseInput, GetChallengesUseCaseOkOutput, StringErrorOutput>, GetChallengesUseCase {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: GetChallengesUseCaseInput) throws -> UseCaseResponse<GetChallengesUseCaseOkOutput, StringErrorOutput> {
        let repository = dependenciesResolver.resolve(for: OneAuthorizationProcessorRepository.self)
        let result = try repository.getChallenges(authorizationId: requestValues.authorizationId)
        switch result {
        case .success(let challenges):
            return .ok(GetChallengesUseCaseOkOutput(challenges: challenges))
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

struct GetChallengesUseCaseInput {
    let authorizationId: String
}

struct GetChallengesUseCaseOkOutput {
    let challenges: [ChallengeRepresentable]
}
