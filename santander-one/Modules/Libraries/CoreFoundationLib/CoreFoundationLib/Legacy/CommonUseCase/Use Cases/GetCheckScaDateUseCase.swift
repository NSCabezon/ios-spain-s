//
//  GetCheckScaDto.swift
//  CommonUseCase
//
//  Created by Ali Ghanbari Dolatshahi on 20/12/21.
//

import SANLegacyLibrary

public final class GetCheckScaDateUseCase: UseCase<Void, GetCheckScaDateOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCheckScaDateOkOutput, StringErrorOutput> {
        let scaManager: BSANScaManager = self.provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO>? = try? scaManager.checkSca()
        guard response?.isSuccess() ?? false,
            let checkScaDTO: CheckScaDTO = try? response?.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(
            GetCheckScaDateOkOutput(scaSystemDate: checkScaDTO.systemDate))
    }
}

public struct GetCheckScaDateOkOutput {
    public let scaSystemDate: Date?
}
