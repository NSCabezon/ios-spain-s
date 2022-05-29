import SANLegacyLibrary
import CoreFoundationLib

class ConfirmCancelOrderUseCase: ConfirmUseCase<ConfirmCancelOrderUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmCancelOrderUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let stocksManager = provider.getBsanStocksManager()
        let stockAccountDTO = requestValues.stockAccount.stockAccountDTO
        let orderDTO = requestValues.order.orderDTO
        let signatureDTO = requestValues.signature.dto
        let response = try stocksManager.setCancellationOrder(orderDTO: orderDTO, signatureDTO: signatureDTO, stockAccountDTO: stockAccountDTO)
        guard response.isSuccess() else {
            let signatureType = try getSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
        return UseCaseResponse.ok()
    }
}

struct ConfirmCancelOrderUseCaseInput {
    let stockAccount: StockAccount
    let order: Order
    let signature: Signature
}
