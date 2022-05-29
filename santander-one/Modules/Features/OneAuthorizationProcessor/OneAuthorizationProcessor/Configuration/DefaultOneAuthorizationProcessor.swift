//
//  DefaultOneAuthorizationProcessor.swift
//  OneAuthorizationProcessor
//
//  Created by José Carlos Estela Anguita on 19/10/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public final class DefaultOneAuthorizationProcessor {
    
    public weak var delegate: OneAuthorizationProcessorDelegate?
    public weak var challengesDelegate: ChallengesHandlerDelegate?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.challengesDelegate = dependenciesResolver.resolve(for: ChallengesHandlerDelegate.self)
        self.delegate = dependenciesResolver.resolve(forOptionalType: OneAuthorizationProcessorDelegate.self)
    }
}

extension DefaultOneAuthorizationProcessor: OneAuthorizationProcessor {
    
    public func start(authorizationId: String, scope: String) {
        authorizeOperation(authorizationId: authorizationId, scope: scope)
            .execute(on: dependenciesResolver.resolve())
            .then { _ in
                return self.getChallenges(authorizationId: authorizationId)
            }.onSuccess { challengesOutput in
                self.startChallenges(challengesOutput.challenges, authorizationId: authorizationId)
            }
    }
}

private extension DefaultOneAuthorizationProcessor {
    
    func authorizeOperation(authorizationId: String, scope: String) -> Scenario<AuthorizeOperationUseCaseInput, AuthorizeOperationUseCaseOkOutput, StringErrorOutput> {
        return Scenario(
            useCase: dependenciesResolver.resolve(for: AuthorizeOperationUseCase.self),
            input: AuthorizeOperationUseCaseInput(authorizationId: authorizationId, scope: scope)
        )
    }
    
    func getChallenges(authorizationId: String) -> Scenario<GetChallengesUseCaseInput, GetChallengesUseCaseOkOutput, StringErrorOutput> {
        return Scenario(
            useCase: dependenciesResolver.resolve(for: GetChallengesUseCase.self),
            input: GetChallengesUseCaseInput(authorizationId: authorizationId)
        )
    }
    
    func confirmChallenges(authorizationId: String, verifications: [ChallengeVerificationRepresentable]) {
        Scenario(
            useCase: dependenciesResolver.resolve(for: ConfirmChallengesUseCase.self),
            input: ConfirmChallengesUseCaseInput(authorizationId: authorizationId, verifications: verifications)
        ).execute(on: dependenciesResolver.resolve())
        .onSuccess {
            self.delegate?.authorizationDidFinishSuccessfully()
        }.onError { error in
            self.delegate?.authorizationDidFinishWithError(error)
        }
    }
    
    func startChallenges(_ challenges: [ChallengeRepresentable], authorizationId: String) {
        let engine = ChallengesEngine(
            challenges: challenges,
            delegate: self.challengesDelegate
        )
        engine.start { result in
            switch result {
            case .success(let verifications):
                self.confirmChallenges(authorizationId: authorizationId, verifications: verifications)
            case .failure(let error):
                self.delegate?.authorizationDidFinishWithError(error)
            }
        }
    }
}
