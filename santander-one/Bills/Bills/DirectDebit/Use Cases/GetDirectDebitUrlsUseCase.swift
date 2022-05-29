//
//  GetDirectDebitUrlsUseCase.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 07/04/2020.
//

import CoreFoundationLib

final class GetDirectDebitUrlsUseCase: UseCase<Void, GetAppConfigOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let appConfig: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void)
        throws -> UseCaseResponse<GetAppConfigOutput, StringErrorOutput> {
            let billsHomePensionUrl = self.appConfig.getString("billsHomePensionUrl")
            let billsHomeUnemploymentBenefitUrl = self.appConfig.getString("billsHomeUnemploymentBenefit")
            return .ok(GetAppConfigOutput(
                billsHomePensionUrl: billsHomePensionUrl,
                billsHomeUnemploymentBenefitUrl: billsHomeUnemploymentBenefitUrl))
    }
}

struct GetAppConfigOutput {
    let billsHomePensionUrl: String?
    let billsHomeUnemploymentBenefitUrl: String?
}
