import SANLegacyLibrary
import CoreFoundationLib

class ConfirmTotalFundTransferUseCase: ConfirmUseCase<ConfirmTotalFundTransferUseCaseInput, ConfirmTotalFundTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmTotalFundTransferUseCaseInput) throws -> UseCaseResponse<ConfirmTotalFundTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let originFund = requestValues.originFund.fundDTO
        let destinationFund = requestValues.destinationFund.fundDTO
        let fundTransfer = requestValues.fundTransfer
        let signature = requestValues.signature
        
        let response = try fundsManager.confirmFundTransferTotal(originFundDTO: originFund, destinationFundDTO: destinationFund, fundTransferDTO: fundTransfer.fundTransferDTO, signatureDTO: signature.dto)
        
        if response.isSuccess() {
            return UseCaseResponse.ok(ConfirmTotalFundTransferUseCaseOkOutput())
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmTotalFundTransferUseCaseInput {
    let originFund: Fund
    let destinationFund: Fund
    let fundTransfer: FundTransfer
    let signature: Signature

    init(originFund: Fund, destinationFund: Fund, fundTransfer: FundTransfer, signature: Signature) {
        self.originFund = originFund
        self.destinationFund = destinationFund
        self.fundTransfer = fundTransfer
        self.signature = signature
    }
}

struct ConfirmTotalFundTransferUseCaseOkOutput {

}
