//
//  GetLoanUseCase.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 29/06/2020.
//

import SANLegacyLibrary

public class GetLoanSimulationLimitsUseCase: UseCase<Void, GetLoanSimulationLimitsUseCaseOutput, StringErrorOutput> {
    
    private let managersProvider: BSANManagersProvider
    
    public init(managersProvider: BSANManagersProvider) {
        self.managersProvider = managersProvider
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLoanSimulationLimitsUseCaseOutput, StringErrorOutput> {
   
        let manager = managersProvider.getBSANLoanSimulatorManager()
        let response = try manager.getLimits()
        if response.isSuccess(), let loanSimulatorLimitsDTO = try response.getResponseData() {
            return UseCaseResponse.ok(GetLoanSimulationLimitsUseCaseOutput(loanLimits: LoanSimulationLimitsEntity(loanSimulatorLimitsDTO)))
        }

        let errorMessage = try response.getErrorMessage()
        return UseCaseResponse.error(StringErrorOutput(errorMessage))

    }
}

public struct GetLoanSimulationLimitsUseCaseOutput {
    public let loanLimits: LoanSimulationLimitsEntity
}

public struct LoanSimulationLimitsEntity: DTOInstantiable {
    public let dto: LoanSimulatorProductLimitsDTO
    
    public init(_ dto: LoanSimulatorProductLimitsDTO) {
        self.dto = dto
    }
    
    public var defaultAmount: AmountEntity? {
        return amountEntityFromInt(dto.defaultAmount)
    }
    
    public var amountFrom: AmountEntity? {
        return amountEntityFromInt(dto.amountFrom)
    }
    
    public var amountUntil: AmountEntity? {
        return amountEntityFromInt(dto.amountUntil)
    }
    
    public var defaultTerm: AmountEntity? {
        return amountEntityFromInt(dto.defaultTerm)
    }
    
    public var termFrom: AmountEntity? {
        return amountEntityFromInt(dto.termFrom)
    }
    
    public var termUntil: AmountEntity? {
        return amountEntityFromInt(dto.termUntil)
    }
    
    private func amountEntityFromInt(_ dtoInt: Int?) -> AmountEntity? {
        guard let amount = dtoInt else { return nil }
        return AmountEntity(value: Decimal(amount))
    }
}

public struct LoanBannerLimitsEntity {
    public let simulationAlreadyInProgress: Bool
    public var amountLimit: Int?
    
    public var amountEntity: AmountEntity? {
        guard let amount = amountLimit else { return nil }
        return AmountEntity(value: Decimal(amount))
    }
    
    public init(simulationAlreadyInProgress: Bool, amountLimit: Int?) {
        self.simulationAlreadyInProgress = simulationAlreadyInProgress
        self.amountLimit = amountLimit
    }
}
