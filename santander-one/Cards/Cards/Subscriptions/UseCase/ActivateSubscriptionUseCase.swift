//
//  ActivateSubscriptionUseCase.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 10/5/21.
//

import CoreFoundationLib
import SANLegacyLibrary

typealias ActivateSubscriptionUseCaseAlias = UseCase<ActivateSubscriptionInput, Void, StringErrorOutput>

final class ActivateSubscriptionUseCase: ActivateSubscriptionUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: ActivateSubscriptionInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanSubscriptionManager()
        let response = try manager.activate(magicPhrase: requestValues.magicPhrase, instaID: requestValues.instaID)
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        return .ok()
    }

}

struct ActivateSubscriptionInput {
    var magicPhrase: String
    var instaID: String
}
