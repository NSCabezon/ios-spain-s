//
//  LogoutUseCase.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 7/9/21.
//

import CoreDomain
import SANLegacyLibrary

public protocol LogoutUseCase: UseCase<Void, Void, StringErrorOutput> {}

public final class DefaultLogoutUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepository = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let sessionRepository = dependenciesResolver.resolve(forOptionalType: UserSessionRepository.self)
        let pullOffersRepository = dependenciesResolver.resolve(for: PullOffersRepositoryProtocol.self)
        _ = appRepository.closeSession()
        _ = pullOffersRepository.reset()
        _ = bsanManagersProvider.getBsanSessionManager().logout()
        sessionRepository?.cleanSession()
        dependenciesResolver.resolve(for: TealiumRepository.self).deleteUser()
        dependenciesResolver.resolve(for: NetInsightRepository.self).deleteUser()
        return UseCaseResponse.ok()
    }
}

extension DefaultLogoutUseCase: LogoutUseCase {}
