import SANLegacyLibrary
import CoreFoundationLib

class ConfirmFundSubscriptionAmountUseCase: ConfirmUseCase<ConfirmFundSubscriptionAmountUseCaseInput, ConfirmFundSubscriptionAmountUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmFundSubscriptionAmountUseCaseInput) throws -> UseCaseResponse<ConfirmFundSubscriptionAmountUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let fundDTO = requestValues.fund.fundDTO
        let amountDTO = requestValues.amount.amountDTO
        let fundSubscriptionDTO = requestValues.fundSubscription.fundSubscriptionDTO
        let signatureDTO = requestValues.signature.dto

        let response = try fundsManager.confirmFundSubscriptionAmount(fundDTO: fundDTO, amountDTO: amountDTO, fundSubscriptionDTO: fundSubscriptionDTO, signatureDTO: signatureDTO)
        
        if response.isSuccess(), let fundSubscriptionConfirmDTO = try response.getResponseData() {
            let fundSubscriptionConfirm = FundSubscriptionConfirm.create(fundSubscriptionConfirmDTO)
            return UseCaseResponse.ok(ConfirmFundSubscriptionAmountUseCaseOkOutput(fundSubscriptionConfirm: fundSubscriptionConfirm))
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmFundSubscriptionAmountUseCaseInput {
    let fund: Fund
    let amount: Amount
    let fundSubscription: FundSubscription
    let signature: Signature

    init(fund: Fund, amount: Amount, fundSubscription: FundSubscription, signature: Signature) {
        self.fund = fund
        self.amount = amount
        self.fundSubscription = fundSubscription
        self.signature = signature
    }
}

struct ConfirmFundSubscriptionAmountUseCaseOkOutput {
    let fundSubscriptionConfirm: FundSubscriptionConfirm
}
