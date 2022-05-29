//
//  ChangeInsuranceSavingAliasUseCase.swift
//  PersonalArea
//
//  Created by Pedro Meira on 12/08/2021.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

protocol ChangeInsuranceSavingAliasUseCaseProtocol: UseCase<ChangeInsuranceSavingAliasUseCaseInput, Void, StringErrorOutput> {}

final class ChangeInsuranceSavingAliasUseCase: UseCase<ChangeInsuranceSavingAliasUseCaseInput, Void, StringErrorOutput> {
    private let insuranceRepository: InsurancesRepository
    
    init(dependenciesResolver: DependenciesResolver) {
        self.insuranceRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: ChangeInsuranceSavingAliasUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let alias = requestValues.alias,
              !alias.isEmpty
        else {
            return UseCaseResponse.error(StringErrorOutput("productsOrder_alert_alias"))
        }
        let dto = requestValues.insuranceSaving.dto
        let response = self.insuranceRepository.updateInsuranceAlias(insuranceRepresentable: dto, newAlias: alias)
        switch response {
        case .success:
            return UseCaseResponse.ok()
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

extension ChangeInsuranceSavingAliasUseCase: ChangeInsuranceSavingAliasUseCaseProtocol {}

struct ChangeInsuranceSavingAliasUseCaseInput {
    let insuranceSaving: InsuranceSavingEntity
    let alias: String?
}
