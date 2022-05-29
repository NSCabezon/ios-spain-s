//
//  DeactivateSubscriptionUseCase.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 10/5/21.
//

import CoreFoundationLib
import SANLegacyLibrary

typealias DeactivateSubscriptionUseCaseAlias = UseCase<DeactivateSubscriptionInput, Void, StringErrorOutput>

final class DeactivateSubscriptionUseCase: DeactivateSubscriptionUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: DeactivateSubscriptionInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanSubscriptionManager()
        let response = try manager.deactivate(magicPhrase: requestValues.magicPhrase, instaID: requestValues.instaID)
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        return .ok()
    }

}

struct DeactivateSubscriptionInput {
    var magicPhrase: String
    var instaID: String
}
