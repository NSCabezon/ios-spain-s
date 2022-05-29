//
//  SingleSignOnUseCase.swift
//  PersonalManager
//
//  Created by alvola on 12/02/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

final class SingleSignOnUseCase: UseCase<SingleSignOnUseCaseInput, Void, StringErrorOutput> {
    
    override public func executeUseCase(requestValues: SingleSignOnUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let provider = requestValues.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager =  provider.getBsanAuthManager()
        let authCredentials = try manager.getAuthCredentials()
        let token = authCredentials.soapTokenCredential
        let passwordData = token.data(using: String.Encoding.utf8)
        let query = KeychainQuery(service: "Santander",
                                  account: "keychainTokenToShare",
                                  accessGroup: requestValues.sharedTokenAccessGroup,
                                  data: passwordData as? NSCoding)
        do {
            try KeychainWrapper().save(query: query)
        } catch {}
        return UseCaseResponse.ok()
    }
}

struct SingleSignOnUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let sharedTokenAccessGroup: String
}
