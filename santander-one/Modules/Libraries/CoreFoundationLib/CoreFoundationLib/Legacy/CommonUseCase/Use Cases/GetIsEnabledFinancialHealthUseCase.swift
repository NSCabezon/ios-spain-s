 //
//  GetIsEnabledFinancialHealthUseCase.swift
//  CoreFoundationLib
//
//  Created by Jose Javier Montes Romero on 7/3/22.
//

 import Foundation
 import CoreDomain

public final class GetIsEnabledFinancialHealthUseCase: UseCase<Void, GetIsEnabledFinancialHealthUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetIsEnabledFinancialHealthUseCaseOkOutput, StringErrorOutput> {
        let appconfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve()
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let visibleAnalysisZoneFromAppConfig = appconfigRepository.getBool("enabledFinancialHealthZone") ?? false
        return .ok(GetIsEnabledFinancialHealthUseCaseOkOutput(isEnabledFinancialHealthZone: visibleAnalysisZoneFromAppConfig))
    }
}

public struct GetIsEnabledFinancialHealthUseCaseOkOutput {
    public let isEnabledFinancialHealthZone: Bool
}
