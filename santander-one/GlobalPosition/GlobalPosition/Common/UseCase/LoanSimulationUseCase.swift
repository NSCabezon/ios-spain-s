//
//  LoanSimulationUseCase.swift
//  GlobalPosition
//
//  Created by César González Palomino on 28/01/2020.
//

import SANLegacyLibrary
import CoreFoundationLib

class LoanSimulationUseCase: UseCase<LoanSimulationUseCaseInput, LoanSimulationUseCaseOutput, StringErrorOutput> {
    
    private let resolver: DependenciesResolver
        
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
    }
    override func executeUseCase(requestValues: LoanSimulationUseCaseInput) throws -> UseCaseResponse<LoanSimulationUseCaseOutput, StringErrorOutput> {
        let loanSimulatorManager = resolver.resolve(for: BSANManagersProvider.self).getBSANLoanSimulatorManager()
        let input = LoanSimulatorDataSend(term: requestValues.months, amount: requestValues.amount)
        let response = try loanSimulatorManager.doSimulation(inputData: input)
        if response.isSuccess(), let dto = try response.getResponseData() {
            
            return UseCaseResponse.ok(LoanSimulationUseCaseOutput(entity: LoanSimulationEntity(dto)))
        }
        
        let errorMessage = try response.getErrorMessage()
        return UseCaseResponse.error(StringErrorOutput(errorMessage))
    }   
}

struct LoanSimulationUseCaseInput {
    let months: Int
    let amount: Int
}

struct LoanSimulationUseCaseOutput {
    let entity: LoanSimulationEntity
}

struct LoanSimulationEntity: DTOInstantiable {
    
    let dto: LoanSimulatorConditionsDTO
    
    init(_ dto: LoanSimulatorConditionsDTO) {
        self.dto = dto
    }
    
    var installmentWithBonus: Double? {
        dto.installmentWithBonus
    }
    
    var loanTotalAmount: AmountEntity? {
        guard let amount = dto.loanTotalAmount else { return nil }
        let amountEntity = AmountEntity(value: Decimal(amount))
        
        return amountEntity
    }
    
    var insurancetotalPrime: Int? {
        dto.insurancetotalPrime
    }
    
    var taeWithBonus: Double? {
        dto.taeWithBonus
    }
    
    var interestType: Double? {
        dto.interestType 
    }
    
    var openingCommission: Double? {
        dto.openingCommission
    }
}
