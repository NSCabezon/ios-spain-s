//
//  CheckStatusSendMoneyTransferUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 7/1/22.
//

import CoreFoundationLib
import TransferOperatives
import SANSpainLibrary

final class CheckStatusSendMoneyTransferUseCase: UseCase<CheckStatusSendMoneyTransferUseCaseInput, CheckStatusSendMoneyTransferUseCaseOkOutputProtocol, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let manager: SpainTransfersRepository
    private var repeats = 0
    private let maxRepeats = 6
    private let timeSleep: UInt32 = 4
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.manager = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: CheckStatusSendMoneyTransferUseCaseInput) throws -> UseCaseResponse<CheckStatusSendMoneyTransferUseCaseOkOutputProtocol, StringErrorOutput> {
        try executeRequest(requestValues: requestValues)
    }
}

private extension CheckStatusSendMoneyTransferUseCase {
    func executeRequest(requestValues: CheckStatusSendMoneyTransferUseCaseInput) throws -> UseCaseResponse<CheckStatusSendMoneyTransferUseCaseOkOutputProtocol, StringErrorOutput> {
        repeats += 1
        guard let reference = requestValues.transferConfirmAccount.referenceRepresentable else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let response = try manager.checkTransferStatus(reference: reference)
        switch response {
        case .success(let data):
            guard let finalResponse = try self.processResponse(response: data.codInfo, requestValues: requestValues) else {
                return UseCaseResponse.ok(CheckStatusSendMoneyTransferUseCaseOkOutput(status: .pending()))
            }
            return finalResponse
        case .failure(let error):
            let errorMsg = error.localizedDescription
            guard let finalResponse = try self.processResponse(response: errorMsg, requestValues: requestValues) else {
                return UseCaseResponse.ok(CheckStatusSendMoneyTransferUseCaseOkOutput(status: .pending()))
            }
            return finalResponse
        }
    }
    
    func processResponse(response: String?, requestValues: CheckStatusSendMoneyTransferUseCaseInput) throws -> UseCaseResponse<CheckStatusSendMoneyTransferUseCaseOkOutputProtocol, StringErrorOutput>? {
        switch response {
        case "PE_0001"?:
            return UseCaseResponse.ok(CheckStatusSendMoneyTransferUseCaseOkOutput(status: .success()))
        case "PE_0002"?:
            return UseCaseResponse.ok(CheckStatusSendMoneyTransferUseCaseOkOutput(status: .error()))
        case "PE_0003"?, "PE__0003"?:
            if repeats < maxRepeats {
                sleep(timeSleep)
                return try executeRequest(requestValues: requestValues)
            } else {
                return UseCaseResponse.ok(CheckStatusSendMoneyTransferUseCaseOkOutput(status: .pending()))
            }
        default:
            return nil
        }
    }
}

extension CheckStatusSendMoneyTransferUseCase: CheckStatusSendMoneyTransferUseCaseProtocol {
    func isImmediateTransfer(type: String) -> Bool {
        let spainType = SpainTransferType(fromServiceString: type)
        switch spainType {
        case .immediate: return true
        default: return false
        }
    }
}

struct CheckStatusSendMoneyTransferUseCaseOkOutput: CheckStatusSendMoneyTransferUseCaseOkOutputProtocol {
    let status: SendMoneyTransferSummaryState
}
