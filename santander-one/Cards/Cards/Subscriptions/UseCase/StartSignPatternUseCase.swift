//
//  StartSignPatternUseCase.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 6/5/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

typealias StartSignPatternUseCaseAlias = UseCase<StartSignPatternInput, StartSignPatternUseCaseOkOutput, GenericErrorSignatureErrorOutput>

final class StartSignPatternUseCase: StartSignPatternUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: StartSignPatternInput) throws -> UseCaseResponse<StartSignPatternUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanSignBasicOperationManager()
        let response = try manager.startSignPattern(requestValues.pattern, instaID: requestValues.instaID)
        guard response.isSuccess(),
            let responseData = try response.getResponseData()
        else {
            let signatureType = try processSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
        return .ok(StartSignPatternUseCaseOkOutput(signBasicOperationEntity: SignBasicOperationEntity(dto: responseData)))
    }
}

struct StartSignPatternUseCaseOkOutput {
    let signBasicOperationEntity: SignBasicOperationEntity
}

struct StartSignPatternInput {
    var pattern: String
    var instaID: String
}
