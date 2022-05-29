//
//  GetContactListWithImageStatusUseCase.swift
//  CommonUseCase
//
//  Created by Boris Chirino Fernandez on 11/02/2021.
//

import CoreFoundationLib

public class GetContactListWithImageStatusUseCase: UseCase<Void, GetContactListWithImageStatusUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetContactListWithImageStatusUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let appConfigKey = BizumContactListConstants.appConfigContactsImageKey
        let retrieveImageFromContacts = appConfigRepository.getBool(appConfigKey) ?? false
        return UseCaseResponse.ok(GetContactListWithImageStatusUseCaseOkOutput(retrieveImageWithContacts: retrieveImageFromContacts))
    }
}

public struct GetContactListWithImageStatusUseCaseOkOutput {
    public let retrieveImageWithContacts: Bool
}
