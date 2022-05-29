//
//  LoadCardsListApplePayStatusUseCase.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 14/10/21.
//

import Foundation
import SANLegacyLibrary

public final class LoadCardsListApplePayStatusUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    private let applePayEnrollment: ApplePayEnrollmentManagerProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.bsanManagersProvider = dependenciesResolver.resolve()
        self.applePayEnrollment = dependenciesResolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let bsanCardsManager = bsanManagersProvider.getBsanCardsManager()
        let addedPasses = applePayEnrollment.alreadyAddedPaymentPasses()
        guard addedPasses.count > 0 else {
            return .ok()
        }
        let bsanResponse = try bsanCardsManager.loadApplePayStatus(for: addedPasses)
        guard bsanResponse.isSuccess() else {
            let errorDescription = try bsanResponse.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
            
        }
        return .ok()
    }
}
