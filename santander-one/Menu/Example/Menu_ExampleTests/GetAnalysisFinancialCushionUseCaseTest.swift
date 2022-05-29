import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData

@testable import Menu_Example
@testable import Menu

class GetAnalysisFinancialCushionUseCaseTest: XCTestCase {
    
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    
    // MARK: LifeCycle
    override func setUp() {
        super.setUp()
        mockDataInjector.register(
            for: \.pullOffersConfig.getPullOffersConfig,
            filename: "pull_offers_configV4_without_cushion"
        )
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: UseCase Tests
    func test_analysisFinancialCushionUseCase_ok() {
        self.dependencies.register(for: PullOffersConfigRepositoryProtocol.self) { resolver in
            return MockPullOffersConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        
        let cushion = 1
        let input = GetAnalysisFinancialCushionUseCaseInput(cushion: cushion)
        
        do {
            
            let response = try getAnalysisFinancialCushionUseCaseTest(input)
            let okOutput = try? response.getOkResult()
            guard let cushionOffer = okOutput?.financialCushionOffer,
                  let greaterAndEqualThan = cushionOffer.greaterAndEqualThan else {
                return
            }
            XCTAssertTrue(cushionOffer.identifier == "1")
            XCTAssertGreaterThanOrEqual(cushion, greaterAndEqualThan)
            XCTAssertLessThan(cushion, cushionOffer.lessThan ?? 30)
            XCTAssertTrue(okOutput?.financialCushionOffer?.title == "Aún tienes margen para mejorar tu capacidad financiera,{{BOLD}} ¡te ayudamos con nuestro tips financieros! {{/BOLD}}")
        } catch {
            XCTFail("GetAnalysisFinancialCushionUseCase: throw exception")
        }
    }
    
    func test_analysisFinancialCushionUseCase_ko() {
        self.dependencies.register(for: PullOffersConfigRepositoryProtocol.self) { resolver in
            return MockPullOffersConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        let cushion = 1
        let input = GetAnalysisFinancialCushionUseCaseInput(cushion: cushion)
        
        do {
            
            let response = try getAnalysisFinancialCushionUseCaseTest(input)
            let errorOutput = try? response.getErrorResult()
            XCTAssertNotNil(errorOutput)
            XCTAssertNil(try? response.getOkResult())
        } catch {
            XCTFail("GetAnalysisFinancialCushionUseCase: throw exception")
        }
    }
}

private extension GetAnalysisFinancialCushionUseCaseTest {
    
    // MARK: Handle useCase response
    func getAnalysisFinancialCushionUseCaseTest(_ input: GetAnalysisFinancialCushionUseCaseInput) throws -> UseCaseResponse<GetAnalysisFinancialCushionUseCaseOkOutput, StringErrorOutput> {
        // returns your useCase response
        let useCase = GetAnalysisFinancialCushionUseCase(dependenciesResolver: self.dependencies)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}
