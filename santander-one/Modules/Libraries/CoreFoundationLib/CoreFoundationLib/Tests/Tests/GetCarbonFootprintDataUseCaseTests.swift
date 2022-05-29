import XCTest
import CoreTestData
import CoreFoundationLib
import CoreDomain
import SANLegacyLibrary

class GetCarbonFootprintDataUseCaseTests: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let mockDataInjector = MockDataInjector()

    override func setUp() {
        super.setUp()
        setDependencies()
    }

    func test_carbonFootprintDataUseCase_withDataInput_responseShouldBeOK() {
        let nodeConfig = ["carbonFootprintShow": "['013', '662', '655']"]
        guard let response = executeGetCarbonFootprintDataUseCase(appconfig: nodeConfig) else {
            XCTFail("unable to create response")
            return
        }
        let output = outputFrom(response)
        XCTAssert(output?.token?.idToken != nil)
        XCTAssertTrue(response.isOkResult)
    }
    
    func test_carbonFootprintDataUseCase_withDataInputAndEmptyBotes_responseShouldBeFailed() {
        let nodeConfig = ["carbonFootprintShow": "[]"]
        guard let response = executeGetCarbonFootprintDataUseCase(appconfig: nodeConfig) else {
            XCTFail("unable to create response")
            return
        }
        XCTAssertTrue(response.isOkResult)
    }
}

private extension GetCarbonFootprintDataUseCaseTests {
    func setDependencies() {
        dependencies.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        dependencies.register(for: CarbonFootprintRepository.self) { _ in
            MockCarbonFootprintRepository(mockDataInjector: self.mockDataInjector)
        }
    }

    func executeGetCarbonFootprintDataUseCase(appconfig: [String: String]? = nil) -> UseCaseResponse<GetCarbonFootprintDataUseCaseOkOutput, StringErrorOutput>? {
        loadMockedData(appconfig: appconfig)
        let usecase = GetCarbonFootprintDataUseCase(dependenciesResolver: self.dependencies)
        guard let response = try? usecase.executeUseCase(requestValues: ()), response.isOkResult else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return response
    }
    
    func outputFrom(_ response: UseCaseResponse<GetCarbonFootprintDataUseCaseOkOutput, StringErrorOutput>) -> GetCarbonFootprintDataUseCaseOkOutput? {
        guard let output = try? response.getOkResult() else {
            return nil
        }
        return output
    }
    
    func loadMockedData(appconfig: [String: String]? = nil) {
        var localconfig: [String: String] = ["enableCarbonFootprint": "true"]
        if let config = appconfig {
            for (key, value) in config {
                localconfig[key] = value
            }
        }
        self.mockDataInjector.register(for: \.appConfigLocalData.getAppConfigLocalData, element: AppConfigDTOMock(defaultConfig: localconfig))
        self.mockDataInjector.register(for: \.carbonFootprint.idToken, filename: "getCarbonFootprint_tokenData")
    }
}
