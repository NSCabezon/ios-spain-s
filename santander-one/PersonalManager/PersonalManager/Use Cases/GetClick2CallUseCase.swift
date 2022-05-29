//
//  GetClick2CallUseCase.swift
//  PersonalManager
//
//  Created by Laura González on 28/09/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetClick2CallUseCase: UseCase<Void, GetClick2CallUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetClick2CallUseCaseOkOutput, StringErrorOutput> {
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let appconfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve()
        guard appconfigRepository.getBool("enableClick2call") == true else {
            return .error(StringErrorOutput(nil))
        }
        let response = try bsanManagersProvider.getBsanManagersManager().loadClick2Call()
        guard
            response.isSuccess(),
            let phone = try response.getResponseData(),
            let formattedPhone = phone.contactPhone.substring(1)
            else {
                return .error(StringErrorOutput(nil))
        }
        return .ok(GetClick2CallUseCaseOkOutput(contactPhone: formattedPhone))
    }
}

struct GetClick2CallUseCaseOkOutput {
    let contactPhone: String
}
