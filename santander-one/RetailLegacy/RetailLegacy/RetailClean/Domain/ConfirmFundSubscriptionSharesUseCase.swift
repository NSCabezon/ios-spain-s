import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class ConfirmFundSubscriptionSharesUseCase: ConfirmUseCase<ConfirmFundSubscriptionSharesUseCaseInput, ConfirmFundSubscriptionSharesUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmFundSubscriptionSharesUseCaseInput) throws -> UseCaseResponse<ConfirmFundSubscriptionSharesUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let fundDTO = requestValues.fund.fundDTO
        let sharesNumber = requestValues.sharesNumber
        let fundSubscriptionDTO = requestValues.fundSubscription.fundSubscriptionDTO
        let signatureDTO = requestValues.signature.dto
        
        let response = try fundsManager.confirmFundSubscriptionShares(fundDTO: fundDTO, sharesNumber: sharesNumber, fundSubscriptionDTO: fundSubscriptionDTO, signatureDTO: signatureDTO)
        
        if response.isSuccess(), let fundSubscriptionConfirmDTO = try response.getResponseData() {
            let fundSubscriptionConfirm = FundSubscriptionConfirm.create(fundSubscriptionConfirmDTO)
            return UseCaseResponse.ok(ConfirmFundSubscriptionSharesUseCaseOkOutput(fundSubscriptionConfirm: fundSubscriptionConfirm))
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmFundSubscriptionSharesUseCaseInput {
    let fund: Fund
    let sharesNumber: Decimal
    let fundSubscription: FundSubscription
    let signature: Signature
}

struct ConfirmFundSubscriptionSharesUseCaseOkOutput {
    let fundSubscriptionConfirm: FundSubscriptionConfirm
}
