//
//  BizumSetupHandler.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 22/3/21.
//

import Operative
import CoreFoundationLib

protocol BizumCommonSetupCapable {
    var dependenciesResolver: DependenciesResolver { get }
    func bizumSetupWithScenario<Input, Output>(_ scenario: Scenario<Input, Output, StringErrorOutput>, onSuccess: @escaping (Output) -> Void)
}

extension BizumCommonSetupCapable where Self: Operative {
    
    func bizumSetupWithScenario<Input, Output>(_ scenario: Scenario<Input, Output, StringErrorOutput>, onSuccess: @escaping (Output) -> Void) {
            scenario
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess(onSuccess)
            .thenOnError(scenario: self.getBizumWebConfigurationWithError)
            .onSuccess { [container = self.container] response in
                container?.handler?.hideOperativeLoading {
                    self.dependencies.resolve(for: BizumHomeModuleCoordinatorDelegate.self).goToBizumWeb(configuration: response.configuration)
                }
            }
    }
}

private extension BizumCommonSetupCapable {
    
    func getBizumWebConfigurationWithError<Error: StringErrorOutput>(_ error: UseCaseError<Error>) -> Scenario<Void, BizumWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
        let useCase = self.dependenciesResolver.resolve(for: BizumWebViewConfigurationUseCaseProtocol.self)
        return Scenario(useCase: useCase)
    }
}
