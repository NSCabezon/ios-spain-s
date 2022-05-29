//
//  BizumActionsAppConfigUseCase.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 16/12/2020.
//

import CoreFoundationLib

final class BizumActionsAppConfigUseCase: UseCase<Void, BizumActionsAppConfigUseCaseOkOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<BizumActionsAppConfigUseCaseOkOutput, StringErrorOutput> {
        let accept = self.appConfigRepository.getBool(BizumConstants.isEnableAcceptRequestMoneyBizumNative) ?? false
        let cancel = self.appConfigRepository.getBool(BizumConstants.isCancelSendMoneyForNotClientByBizum) ?? false
        let refund = self.appConfigRepository.getBool(BizumConstants.isReturnMoneyReceivedBizumNativeEnabled) ?? false
        return .ok(BizumActionsAppConfigUseCaseOkOutput(cancelEnabled: cancel, acceptEnabled: accept, refundEnabled: refund))
    }
}

struct BizumActionsAppConfigUseCaseOkOutput {
    let cancelEnabled: Bool
    let acceptEnabled: Bool
    let refundEnabled: Bool
}
