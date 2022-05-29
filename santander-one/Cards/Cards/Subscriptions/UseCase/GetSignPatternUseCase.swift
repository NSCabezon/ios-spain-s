//
//  GetSignPatternUseCase.swift
//  Cards
//
//  Created by Rubén Márquez Fernández on 6/5/21.
//

import Foundation

import CoreFoundationLib
import SANLegacyLibrary

typealias GetSignPatternUseCaseAlias = UseCase<Void, GetSignPatternUseCaseOkOutput, StringErrorOutput>

final class GetSignPatternUseCase: GetSignPatternUseCaseAlias {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSignPatternUseCaseOkOutput, StringErrorOutput> {
        let provider: BSANManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanSignBasicOperationManager()
        let response = try manager.getSignaturePattern()
        guard response.isSuccess(),
            let responseData = try response.getResponseData()
        else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        return .ok(GetSignPatternUseCaseOkOutput(pattern: responseData.pattern))
    }
}

struct GetSignPatternUseCaseOkOutput {
    let pattern: SignPatternType?

    init(pattern: String) {
        self.pattern = SignPatternType(rawValue: pattern)
    }
}
