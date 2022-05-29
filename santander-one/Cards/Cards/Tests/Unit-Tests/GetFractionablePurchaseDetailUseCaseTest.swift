import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class GetFractionablePurchaseDetailUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    
    override func setUp() {
        super.setUp()
        self.setupCommonsDependencies()
        self.registerFinanceableMovementDetail()
    }

    override func tearDown() {
        super.tearDown()
        self.dependenciesResolver.clean()
    }

    func test_useCase_withMovIdAndPanInputs_responseShouldBeOk() {
        let input = FractionablePurchaseDetailUseCaseInput(movID: "0049007550219289432021032400600000021", pan: "4036160104210077")
        do {
            let response = try getFractionablePurchaseDetailUseCase(input)
            XCTAssertTrue(response.isOkResult)
        } catch {
            XCTFail("FractionablePurchaseDetailUseCase: throw")
        }
    }
    
    func test_useCase_withMovIdAndPanInputs_responseShouldBeKo() {
        let input = FractionablePurchaseDetailUseCaseInput(movID: "", pan: "")
        do {
            let response = try getFractionablePurchaseDetailUseCase(input)
            XCTAssertFalse(response.isOkResult)
        } catch {
            XCTFail("FractionablePurchaseDetailUseCase: throw")
        }
    }
}

private extension GetFractionablePurchaseDetailUseCaseTest {
    func registerFinanceableMovementDetail() {
        self.mockDataInjector.register(
            for: \.cardsData.getFinanceableMovementDetail,
            filename: "financeableMovementDetail"
        )
    }
    
    // MARK: Handle data
    func getFractionablePurchaseDetailUseCase(_ input: FractionablePurchaseDetailUseCaseInput) throws -> UseCaseResponse<FractionablePurchaseDetailUseCaseOkOutput, StringErrorOutput> {
        let useCase = GetFractionablePurchaseDetailUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func outputFrom(_ response: UseCaseResponse<FractionablePurchaseDetailUseCaseOkOutput, StringErrorOutput>) -> FractionablePurchaseDetailUseCaseOkOutput? {
        return try? response.getOkResult()
    }
}

extension GetFractionablePurchaseDetailUseCaseTest: RegisterCommonDependenciesProtocol { }
