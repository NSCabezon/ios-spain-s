import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmCardModifyPaymentMethodUseCase: UseCase<ConfirmCardModifyPaymentMethodUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmCardModifyPaymentMethodUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let cardsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        let changePayment = requestValues.changePayment
        guard let referenceStandardDTO = changePayment.referenceStandard,
            let hiddenReferenceStandardDTO = changePayment.hiddenReferenceStandard else {
                return .error(StringErrorOutput(nil))
        }
        
        let changePaymentMethodConfirmationInput = ChangePaymentMethodConfirmationInput(
            referenceStandard: referenceStandardDTO,
            hiddenReferenceStandard: hiddenReferenceStandardDTO,
            selectedAmount: requestValues.amount.dto,
            currentPaymentMethod: changePayment.currentPaymentMethod,
            currentPaymentMethodMode: changePayment.currentPaymentMethodMode ?? "",
            currentSettlementType: changePayment.currentSettlementType ?? "",
            marketCode: changePayment.marketCode ?? "",
            hiddenMarketCode: changePayment.hiddenMarketCode ?? "",
            hiddenPaymentMethodMode: changePayment.hiddenPaymentMethodMode ?? "",
            selectedPaymentMethod: requestValues.selectedPaymentMethod.dto
        )
        let response = try cardsManager.confirmPaymentChange(cardDTO: requestValues.card.dto, input: changePaymentMethodConfirmationInput)
        guard response.isSuccess() else { return .error(StringErrorOutput(try response.getErrorMessage()))}

        return .ok()
    }
}

struct ConfirmCardModifyPaymentMethodUseCaseInput {
    let card: CardEntity
    let changePayment: ChangePaymentEntity
    let selectedPaymentMethod: PaymentMethodEntity
    let amount: AmountEntity
}
