import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class CheckStatusOnePayTransferUseCase: UseCase<CheckStatusOnePayTransferUseCaseInput, CheckStatusOnePayTransferUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private var repeats = 0
    private let maxRepeats = 6
    private let timeSleep: UInt32 = 4
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: CheckStatusOnePayTransferUseCaseInput) throws -> UseCaseResponse<CheckStatusOnePayTransferUseCaseOkOutput, StringErrorOutput> {
        return try executeRequest(requestValues: requestValues)
    }
    
    private func processResponse(response: String?, requestValues: CheckStatusOnePayTransferUseCaseInput) throws -> UseCaseResponse<CheckStatusOnePayTransferUseCaseOkOutput, StringErrorOutput>? {
        switch response {
        case "PE_0001"?:
            return UseCaseResponse.ok(CheckStatusOnePayTransferUseCaseOkOutput(status: .success))
        case "PE_0002"?:
            return UseCaseResponse.ok(CheckStatusOnePayTransferUseCaseOkOutput(status: .error))
        case "PE_0003"?, "PE__0003"?:
            if repeats < maxRepeats {
                sleep(timeSleep)
                return try executeRequest(requestValues: requestValues)
            } else {
                return UseCaseResponse.ok(CheckStatusOnePayTransferUseCaseOkOutput(status: .pending))
            }
        default:
            return nil
        }
    }
    
    private func executeRequest(requestValues: CheckStatusOnePayTransferUseCaseInput) throws -> UseCaseResponse<CheckStatusOnePayTransferUseCaseOkOutput, StringErrorOutput> {
        repeats += 1
        let manager = provider.getBsanTransfersManager()
        guard let reference = requestValues.transferConfirmAccount.dto.reference else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let response = try manager.checkTransferStatus(referenceDTO: reference)
        if response.isSuccess(), let data = try response.getResponseData() {
            guard let finalResponse = try processResponse(response: data.codInfo, requestValues: requestValues) else {
                return UseCaseResponse.ok(CheckStatusOnePayTransferUseCaseOkOutput(status: .pending))
            }
            return finalResponse
        } else {
            let errorMsg = try response.getErrorMessage()
            guard let finalResponse = try processResponse(response: errorMsg, requestValues: requestValues) else {
                return UseCaseResponse.error(StringErrorOutput(errorMsg))
            }
            return finalResponse
        }
    }
}

struct CheckStatusOnePayTransferUseCaseInput {
    let transferConfirmAccount: TransferConfirmAccount
}

struct CheckStatusOnePayTransferUseCaseOkOutput {
    let status: OnePayTransferSummaryState
}
