import SANLegacyLibrary
import CoreFoundationLib

class ConfirmPartialAmountFundTransferUseCase: ConfirmUseCase<ConfirmPartialAmountFundTransferUseCaseInput, ConfirmPartialAmountFundTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmPartialAmountFundTransferUseCaseInput) throws -> UseCaseResponse<ConfirmPartialAmountFundTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let originFund = requestValues.originFund.fundDTO
        let destinationFund = requestValues.destinationFund.fundDTO
        let fundTransfer = requestValues.fundTransfer
        let amount = requestValues.amount.amountDTO
        let signature = requestValues.signature
        
        let response = try fundsManager.confirmFundTransferPartialByAmount(originFundDTO: originFund, destinationFundDTO: destinationFund, fundTransferDTO: fundTransfer.fundTransferDTO, amountDTO: amount, signatureDTO: signature.dto)
        
        if response.isSuccess() {
            return UseCaseResponse.ok(ConfirmPartialAmountFundTransferUseCaseOkOutput())
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmPartialAmountFundTransferUseCaseInput {
    let originFund: Fund
    let destinationFund: Fund
    let fundTransfer: FundTransfer
    let amount: Amount
    let signature: Signature

    init(originFund: Fund, destinationFund: Fund, fundTransfer: FundTransfer, amount: Amount, signature: Signature) {
        self.originFund = originFund
        self.destinationFund = destinationFund
        self.fundTransfer = fundTransfer
        self.amount = amount
        self.signature = signature
    }
}

struct ConfirmPartialAmountFundTransferUseCaseOkOutput {
    
}
