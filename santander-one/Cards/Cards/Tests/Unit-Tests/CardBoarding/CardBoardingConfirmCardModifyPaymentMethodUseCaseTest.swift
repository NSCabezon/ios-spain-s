import XCTest
import CoreTestData
import CoreFoundationLib
import SANLegacyLibrary
@testable import Cards

final class CardBoardingConfirmCardModifyPaymentMethodUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    let cardsServiceInjector = CardsServiceInjector()
    private var cardEntity: CardEntity!
    
    override func setUp() {
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setupCommonsDependencies()
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard globalPosition.cards.count >= 1 else { return }
        self.cardEntity = globalPosition.cards.first(where: { $0.isCreditCard })
    }

    override func tearDown() {
        self.dependenciesResolver.clean()
        self.cardEntity = nil
    }
    
    // swiftlint:disable force_try
    func test_useCase_given_an_incomplete_ChangePayment_data_then_result_is_an_error() {
        // G
        let changePayment = self.getIncompleteChangePayment(currentPaymentMethod: .monthlyPayment)
        let newPaymentMethod = PaymentMethodEntity(self.getFixedFeeMethod())
        let amount = AmountEntity(value: 75)
        // W
        let input = ConfirmCardModifyPaymentMethodUseCaseInput(card: self.cardEntity,
                                                               changePayment: changePayment,
                                                               selectedPaymentMethod: newPaymentMethod,
                                                               amount: amount)
        let useCase = ConfirmCardModifyPaymentMethodUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try! useCase.executeUseCase(requestValues: input).getErrorResult()
        // T
        XCTAssertNotNil(response)
    }
    
    func test_useCase_given_a_complete_ChangePayment_data_then_result_is_ok() {
        // G
        let changePayment = self.getCompleteChangePayment(currentPaymentMethod: .monthlyPayment)
        let newPaymentMethod = PaymentMethodEntity(self.getFixedFeeMethod())
        let amount = AmountEntity(value: 75)
        // W
        let input = ConfirmCardModifyPaymentMethodUseCaseInput(card: self.cardEntity,
                                                               changePayment: changePayment,
                                                               selectedPaymentMethod: newPaymentMethod,
                                                               amount: amount)
        let useCase = ConfirmCardModifyPaymentMethodUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try! useCase.executeUseCase(requestValues: input).isOkResult
        // T
        XCTAssertTrue(response)
    }
    // swiftlint:enable force_try
}

private extension CardBoardingConfirmCardModifyPaymentMethodUseCaseTest {
    func getIncompleteChangePayment(currentPaymentMethod: PaymentMethodType) -> ChangePaymentEntity {
        let paymentMethodList = [self.getMonthlyMethod(), self.getDeferredMethod(), self.getFixedFeeMethod()]
        var changeDTO = ChangePaymentDTO()
        changeDTO.paymentMethodList = paymentMethodList
        changeDTO.currentPaymentMethod = currentPaymentMethod
        return ChangePaymentEntity(changeDTO)
    }
    
    func getCompleteChangePayment(currentPaymentMethod: PaymentMethodType) -> ChangePaymentEntity {
        let paymentMethodList = [self.getMonthlyMethod(), self.getDeferredMethod(), self.getFixedFeeMethod()]
        var productSubtype = ProductSubtypeDTO()
        productSubtype.company = ""
        productSubtype.productSubtype = ""
        productSubtype.productType = ""
        var referenceStandardDTO = ReferenceStandardDTO()
        referenceStandardDTO.productSubtypeDTO = productSubtype
        referenceStandardDTO.standardCode = ""
        var changeDTO = ChangePaymentDTO()
        changeDTO.paymentMethodList = paymentMethodList
        changeDTO.currentPaymentMethod = currentPaymentMethod
        changeDTO.referenceStandard = referenceStandardDTO
        changeDTO.hiddenReferenceStandard = referenceStandardDTO
        return ChangePaymentEntity(changeDTO)
    }
    
    func getMonthlyMethod() -> PaymentMethodDTO {
        var paymentMethodDTO = PaymentMethodDTO()
        paymentMethodDTO.paymentMethod = .monthlyPayment
        return paymentMethodDTO
    }
    
    func getDeferredMethod() -> PaymentMethodDTO {
        var paymentMethodDTO = PaymentMethodDTO()
        paymentMethodDTO.paymentMethod = .deferredPayment
        paymentMethodDTO.feeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.incModeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.maxModeAmount = AmountDTO(value: 450, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minAmortAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minModeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        return paymentMethodDTO
    }
    
    func getFixedFeeMethod() -> PaymentMethodDTO {
        var paymentMethodDTO = PaymentMethodDTO()
        paymentMethodDTO.paymentMethod = .deferredPayment
        paymentMethodDTO.feeAmount = AmountDTO(value: 50, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.incModeAmount = AmountDTO(value: 50, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.maxModeAmount = AmountDTO(value: 500, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minAmortAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minModeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        return paymentMethodDTO
    }
}

extension CardBoardingConfirmCardModifyPaymentMethodUseCaseTest: RegisterCommonDependenciesProtocol { }
