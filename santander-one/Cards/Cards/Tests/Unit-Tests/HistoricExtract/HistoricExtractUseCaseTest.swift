import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class HistoricExtractUseCaseTest: XCTestCase {
    var mockDataInjector = MockDataInjector()
    private var cardsServiceInjector = CardsServiceInjector()
    internal var dependenciesResolver = DependenciesDefault()
    
    override func setUp() {
        super.setUp()
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setupCommonsDependencies()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }
    
    // MARK: UseCase Success
    func test_useCase_withCardEntityAndDifferernceBetweenMonthsInputs_responseShouldBeOk() {
        // Prepare
        self.registerSettlementDetail()
        let newGlobalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let card = newGlobalPosition.cards.first else {
            return XCTFail("Couldn't load globalPosition | card")
        }
        // Execute
        do {
            let response = try historicExtractUseCase(card, differenceBetweenMonths: 1)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("HistoricExtactUseCase: throw")
        }
    }
    
    // MARK: UseCase Error
    func test_useCase_withCustomCardEntityAndDifferernceBetweenMonthsInputs_responseShouldBeError() {
        // Prepare
        let newGlobalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let card = newGlobalPosition.cards.first else {
            return XCTFail("Couldn't load globalPosition | card")
        }
        var newCardDTO = card.dto
        newCardDTO.contract = nil
        let newCardEntity = CardEntity(newCardDTO)
        // Execute
        do {
            let response = try historicExtractUseCase(newCardEntity, differenceBetweenMonths: 0)
            XCTAssertFalse(response.isOkResult, "HistoricExtractUseCase: Error in response result")
        } catch {
            XCTFail("HistoricExtactUseCase: throw")
        }
    }
}

private extension HistoricExtractUseCaseTest {
    
    func historicExtractUseCase(_ cardEntity: CardEntity, differenceBetweenMonths: Int) throws -> UseCaseResponse<GetHistoricExtractUseCaseOkOutput, StringErrorOutput> {
        let useCase = HistoricExtractUseCase(dependenciesResolver: self.dependenciesResolver)
        let input = GetHistoricExtractUseCaseInput(card: cardEntity, differenceBetweenMonths: differenceBetweenMonths)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func registerSettlementDetail() {
        self.mockDataInjector.register(
            for: \.cardsData.getCardSettlementDetail,
            filename: "getDetalleLiquidacion"
        )
    }
}

extension HistoricExtractUseCaseTest: RegisterCommonDependenciesProtocol { }
