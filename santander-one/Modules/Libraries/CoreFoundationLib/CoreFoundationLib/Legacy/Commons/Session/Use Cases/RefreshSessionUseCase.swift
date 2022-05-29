//
//  RefreshSessionUseCase.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 6/9/21.
//

import SANLegacyLibrary
import CoreDomain

public protocol RefreshSessionUseCase: UseCase<Void, Void, StringErrorOutput> {}

public final class DefaultRefreshSessionUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let response = try provider.getBsanAuthManager().refreshToken()
        if response.isSuccess() {
            let token = try self.provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
            self.dependenciesResolver.resolve(forOptionalType: UserSessionRepository.self)?
                .saveToken(token)
            return .ok()
        } else {
            let errorResponse = StringErrorOutput(try response.getErrorMessage())
            return .error(errorResponse)
        }
    }
}

extension DefaultRefreshSessionUseCase: RefreshSessionUseCase {}
