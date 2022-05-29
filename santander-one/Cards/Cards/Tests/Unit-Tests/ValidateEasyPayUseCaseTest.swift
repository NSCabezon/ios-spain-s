import XCTest
import CoreTestData
import CoreFoundationLib
import SANLegacyLibrary
@testable import Cards

final class ValidateEasyPayUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    private var cardsServiceInjector = CardsServiceInjector()
    private var cardEntity: CardEntity!
    private var cardTransactionEntity: CardTransactionEntity!
    private var feeDataEntity: FeeDataEntity!

    override func setUp() {
        super.setUp()
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setupCommonsDependencies()
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard globalPosition.cards.count >= 1 else { return }
        self.cardEntity = globalPosition.cards.first(where: { $0.cardType == .credit })
        self.cardTransactionEntity = CardTransactionEntity(CardTransactionDTO())
        self.feeDataEntity = FeeDataEntity(FeeDataDTO())
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }

    func test_useCase_withInput_responseShouldBeOk() {
        self.registerAmortizationEasyPay()
        let input = ValidateEasyPayUseCaseInput(card: self.cardEntity,
                                                cardTransaction: cardTransactionEntity,
                                                feeData: feeDataEntity,
                                                numFeesSelected: "3",
                                                balanceCode: 11,
                                                movementIndex: 2)
        do {
            let response = try getAmortizationEasyPayRequest(input: input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("ValidateEasyPayUseCase: throw")
        }
    }
    
    func test_useCase_withInput_responseShouldBeError() {
        let input = ValidateEasyPayUseCaseInput(card: self.cardEntity,
                                                cardTransaction: cardTransactionEntity,
                                                feeData: feeDataEntity,
                                                numFeesSelected: "3",
                                                balanceCode: 11,
                                                movementIndex: 2)
        do {
            let response = try getAmortizationEasyPayRequest(input: input)
            XCTAssertFalse(response.isOkResult)
        } catch {
            XCTFail("ValidateEasyPayUseCase: throw")
        }
    }

    func test_response() {
        self.registerAmortizationEasyPay()
        let input = ValidateEasyPayUseCaseInput(card: self.cardEntity,
                                                cardTransaction: cardTransactionEntity,
                                                feeData: feeDataEntity,
                                                numFeesSelected: "3",
                                                balanceCode: 11,
                                                movementIndex: 2)
        do {
            let response = try getAmortizationEasyPayRequest(input: input)
            let output = outputFrom(response)
            XCTAssertTrue(output?.easyPayAmortization.amortizations.count == 3)
            XCTAssertTrue(output?.easyPayAmortization.amortizations[1].interestAmount?.value?.description == "1.71")
            XCTAssertTrue(output?.easyPayAmortization.amortizations[0].pendingAmount?.value?.description == "114.17")
            XCTAssertTrue(output?.easyPayAmortization.amortizations[2].totalFeeAmount?.value?.description == "58.36")
            XCTAssertTrue(output?.easyPayAmortization.amortizations[1].amortizedAmount?.value?.description == "56.67")
        } catch {
            XCTFail("ValidateEasyPayUseCase: throw")
        }
    }
}

extension ValidateEasyPayUseCaseTest: RegisterCommonDependenciesProtocol { }

private extension ValidateEasyPayUseCaseTest {
    
    func registerAmortizationEasyPay() {
        self.mockDataInjector.register(
            for: \.cardsData.getEasyPayAmortization,
            filename: "getAmortizationEasyPay"
        )
    }
    
    func getAmortizationEasyPayRequest(input: ValidateEasyPayUseCaseInput) throws -> UseCaseResponse<ValidateEasyPayUseCaseOkOutput, StringErrorOutput> {
        let useCase = ValidateEasyPayUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func outputFrom(_ response: UseCaseResponse<ValidateEasyPayUseCaseOkOutput, StringErrorOutput>) -> ValidateEasyPayUseCaseOkOutput? {
        let output = try? response.getOkResult()
        return output
    }
}
