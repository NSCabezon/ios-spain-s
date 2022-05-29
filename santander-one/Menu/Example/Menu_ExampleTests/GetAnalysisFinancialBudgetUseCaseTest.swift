import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import SANLegacyLibrary
import CoreTestData

@testable import Menu_Example
@testable import Menu

class GetAnalysisFinancialBudgetUseCaseTest: XCTestCase {
    
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    
    // MARK: LifeCycle
    override func setUp() {
        super.setUp()
        setUpDependencies()
        mockDataInjector.register(
            for: \.pullOffersConfig.getPullOffersConfig,
            filename: "pull_offers_configV4_without_cushion"
        )
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: UseCase Tests
    func test_analysisFinancialBudgetUseCase_ok() {
        self.dependencies.register(for: PullOffersConfigRepositoryProtocol.self) { resolver in
            return MockPullOffersConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        let financialBudget = 14, currentDayNumber = 2
        let input = GetAnalysisFinancialBudgetHelpUseCaseInput(financialBudgetMonths: financialBudget, currentDayNumber: currentDayNumber)
        do {
            let response = try getAnalysisFinancialBudgetUseCaseTest(input)
            let okOutput = try? response.getOkResult()
            guard let budget = okOutput?.financialBudgetOffer,
                  let budgteGreaterAndEqualThan = budget.currentBudget.greaterAndEqualThan,
                  let currentDayGreaterAndEqualThan = budget.currentDay.greaterAndEqualThan else {
                return
            }
            XCTAssertTrue(budget.identifier == "1")
            XCTAssertGreaterThanOrEqual(financialBudget, budgteGreaterAndEqualThan)
            XCTAssertLessThan(financialBudget, budget.currentBudget.lessThan ?? 30)
            XCTAssertGreaterThanOrEqual(currentDayNumber, currentDayGreaterAndEqualThan)
            XCTAssertLessThan(currentDayNumber, budget.currentDay.lessThan ?? 30)
            XCTAssertTrue(okOutput?.financialBudgetOffer?.title == "Llevas gastado menos de la mitad de tu presupuesto. {{BOLD}} ¡Vas por muy buen camino! {{/BOLD}}")
        } catch {
            XCTFail("GetAnalysisFinancialBudgetUseCase: throw exception")
        }
    }
    
    func test_analysisFinancialBudgetUseCase_ko() {
        self.dependencies.register(for: PullOffersConfigRepositoryProtocol.self) { resolver in
            return MockPullOffersConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        let financialBudget = 14, currentDayNumber = 2
        let input = GetAnalysisFinancialBudgetHelpUseCaseInput(financialBudgetMonths: financialBudget, currentDayNumber: currentDayNumber)
        do {
            let response = try getAnalysisFinancialBudgetUseCaseTest(input)
            let errorOutput = try? response.getErrorResult()
            XCTAssertNotNil(errorOutput)
            XCTAssertNil(try? response.getOkResult())
        } catch {
            XCTFail("GetAnalysisFinancialBudgetUseCase: throw exception")
        }
    }
    
    func test_analysisFinancialBudgetUseCase_offerNil() {
        self.dependencies.register(for: PullOffersConfigRepositoryProtocol.self) { resolver in
            return MockPullOffersConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        let financialBudget = 25, currentDayNumber = 2
        let input = GetAnalysisFinancialBudgetHelpUseCaseInput(financialBudgetMonths: financialBudget, currentDayNumber: currentDayNumber)
        do {   
            let response = try getAnalysisFinancialBudgetUseCaseTest(input)
            let okOutput = try? response.getOkResult()
            guard let budget = okOutput?.financialBudgetOffer,
                  let budgteGreaterAndEqualThan = budget.currentBudget.greaterAndEqualThan,
                  let currentDayGreaterAndEqualThan = budget.currentDay.greaterAndEqualThan else {
                return
            }
            XCTAssertTrue(budget.identifier == "3")
            XCTAssertGreaterThanOrEqual(financialBudget, budgteGreaterAndEqualThan)
            XCTAssertLessThan(financialBudget, budget.currentBudget.lessThan ?? 30)
            XCTAssertGreaterThanOrEqual(currentDayNumber, currentDayGreaterAndEqualThan)
            XCTAssertLessThan(currentDayNumber, budget.currentDay.lessThan ?? 30)
            XCTAssertTrue(okOutput?.financialBudgetOffer?.title == "{{BOLD}}¡Aviso a navegantes! {{/BOLD}}Llevas una cuarta parte de tu presupuesto gastada.")
            XCTAssertNil(budget.offer)
            XCTAssertNil(budget.offersId)
        } catch {
            XCTFail("GetAnalysisFinancialBudgetUseCase: throw exception")
        }
    }
}

private extension GetAnalysisFinancialBudgetUseCaseTest {
    
    func setUpDependencies() {
        self.dependencies.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
                   MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        self.dependencies.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
    }
    
    // MARK: Handle useCase response
    func getAnalysisFinancialBudgetUseCaseTest(_ input: GetAnalysisFinancialBudgetHelpUseCaseInput) throws -> UseCaseResponse<GetAnalysisFinancialBudgetHelpUseCaseOkOutput, StringErrorOutput> {
        // returns your useCase response
        let useCase = GetAnalysisFinancialBudgetHelpUseCase(dependenciesResolver: self.dependencies)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}
