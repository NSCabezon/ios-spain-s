//
//  FinancingDistributionUseCase.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 02/09/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

class FinancingDistributionUseCase: UseCase<Void, FinancingDistributionUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    private var managersProvider: BSANManagersProvider
    private var financialAgregatorManager: BSANFinancialAgregatorManager
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.financialAgregatorManager = self.managersProvider.getFinancialAgregatorManager()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<FinancingDistributionUseCaseOkOutput, StringErrorOutput> {
        let response = try self.financialAgregatorManager.getFinancialAgregator()
        if response.isSuccess(),
           let respDto = try response.getResponseData() {
            let entity = FinanceDistributionEntity(respDto)
            return .ok(FinancingDistributionUseCaseOkOutput(financialAgregatorEntity: entity))
        }
        return .error(StringErrorOutput( try response.getErrorMessage()))
    }
}

struct FinancingDistributionUseCaseOkOutput {
    let financialAgregatorEntity: FinanceDistributionEntity
    var productsGroupCount: Int {
        financialAgregatorEntity.groupCount
    }
}
