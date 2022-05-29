import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmCardModifyPaymentFormUseCase: UseCase<ConfirmCardModifyPaymentFormUseCaseInput, Void, ConfirmCardModifyPaymentFormCaseUseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmCardModifyPaymentFormUseCaseInput) throws -> UseCaseResponse<Void, ConfirmCardModifyPaymentFormCaseUseErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let changePayment = requestValues.changePayment
        let selectedPaymentMethod = requestValues.selectedPaymentMethod
        let amountSelected = requestValues.amount
        
        let changePaymentMethodConfirmation = ChangePaymentMethodConfirmation.create(changePayment: changePayment,
                                                                                     selectedPaymentMethod: selectedPaymentMethod.dto,
                                                                                     amount: amountSelected.amountDTO)
        
        guard let changePaymentMethodConfirmationDTO = changePaymentMethodConfirmation?.dto else {
            return .error(ConfirmCardModifyPaymentFormCaseUseErrorOutput(nil))
        }
        
        let response = try provider.getBsanCardsManager().confirmPaymentChange(cardDTO: cardDTO,
                                                                               input: changePaymentMethodConfirmationDTO)
        
        guard response.isSuccess() else {
            return .error(ConfirmCardModifyPaymentFormCaseUseErrorOutput(try response.getErrorMessage()))
        }
        return .ok()
    }
}

struct ConfirmCardModifyPaymentFormUseCaseInput {
    let card: Card
    let changePayment: ChangePayment
    let selectedPaymentMethod: PaymentMethod
    let amount: Amount
}

class ConfirmCardModifyPaymentFormCaseUseErrorOutput: StringErrorOutput {}
