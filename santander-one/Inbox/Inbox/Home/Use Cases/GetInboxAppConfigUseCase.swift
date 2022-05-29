//
//  GetInboxAppConfigUseCase.swift
//  Inbox
//
//  Created by Cristobal Ramos Laina on 15/04/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetInboxAppConfigUseCase: UseCase<Void, GetDocumentationUseCaseOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetDocumentationUseCaseOutput, StringErrorOutput> {
        let isPersonalDocsEnabled = appConfigRepository.getBool("enablePersonaldoc") ?? false
        let isEcommerceEnabled = appConfigRepository.getBool(EcommerceConstants.enableEcommerceAppConfig) ?? false
        return .ok(
            GetDocumentationUseCaseOutput(
                isPersonalDocsEnabled: isPersonalDocsEnabled,
                isEcommerceEnabled: isEcommerceEnabled
            )
        )
    }
}

struct GetDocumentationUseCaseOutput {
    let isPersonalDocsEnabled: Bool
    let isEcommerceEnabled: Bool
}
