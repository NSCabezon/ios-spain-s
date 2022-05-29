//
//  GetAppConfiguration.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/12/20.
//

import Foundation
import CoreFoundationLib

final class GetAppConfigurationUseCase: UseCase<Void, GetAppConfigurationOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let appConfig: AppConfigRepositoryProtocol
    let localAppConfig: LocalAppConfig
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.localAppConfig = self.dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void)
        throws -> UseCaseResponse<GetAppConfigurationOutput, StringErrorOutput> {
            let isFutureBillEnable = self.appConfig.getBool("enableBillsHomeFutureBills") == true
            let isTimeLineEnable = self.appConfig.getBool("enableTimeLine") == true && self.localAppConfig.isEnabledTimeline == true
            let searchEnabled = self.appConfig.getBool("enableGlobalSearch") ?? false
            let isBillEmitterPaymentEnable = self.appConfig.getBool("enableBillEmittersPayment") == true
            return .ok(GetAppConfigurationOutput(
                isTimeLineEnable: isTimeLineEnable,
                isFutureBillsEnable: isFutureBillEnable,
                isGlobalSearchEnabled: searchEnabled,
                isBillEmitterPaymentEnable: isBillEmitterPaymentEnable))
    }
}

struct GetAppConfigurationOutput {
    let isTimeLineEnable: Bool
    let isFutureBillsEnable: Bool
    let isGlobalSearchEnabled: Bool
    let isBillEmitterPaymentEnable: Bool
}
