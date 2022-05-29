//
//  AuthorizeOperationUseCase.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 4/10/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol AuthorizeOperationUseCase: UseCase<AuthorizeOperationUseCaseInput, AuthorizeOperationUseCaseOkOutput, StringErrorOutput> {}

final class DefaultAuthorizeOperationUseCase: UseCase<AuthorizeOperationUseCaseInput, AuthorizeOperationUseCaseOkOutput, StringErrorOutput>, AuthorizeOperationUseCase {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: AuthorizeOperationUseCaseInput) throws -> UseCaseResponse<AuthorizeOperationUseCaseOkOutput, StringErrorOutput> {
        let repository = dependenciesResolver.resolve(for: OneAuthorizationProcessorRepository.self)
        let result = try repository.authorizeOperation(authorizationId: requestValues.authorizationId, scope: requestValues.scope)
        switch result {
        case .success(let redirect):
            return .ok(AuthorizeOperationUseCaseOkOutput(redirectUri: redirect.uri))
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

struct AuthorizeOperationUseCaseInput {
    let authorizationId: String
    let scope: String
}

struct AuthorizeOperationUseCaseOkOutput {
    let redirectUri: String
}
