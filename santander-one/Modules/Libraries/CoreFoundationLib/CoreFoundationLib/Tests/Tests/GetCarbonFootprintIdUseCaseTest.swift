import XCTest
import CoreTestData
import CoreFoundationLib
import CoreDomain
import SANLegacyLibrary

class GetCarbonFootprintIdUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let mockDataInjector = MockDataInjector()

    override func setUp() {
        super.setUp()
        setDependencies()
    }

    func test_carbonFootprintIdUseCase_withIdInput_responseShouldBeOK() {
        let nodeConfig = ["carbonFootprintShow": "['013', '662', '655']"]
        let input = GetCarbonFootprintIdUseCaseInput(realmId: "HuellaCarbono")
        guard let response = executeGetCarbonFootprintIdUseCase(
            appconfig: nodeConfig,
            input: input
        ) else {
            XCTFail("unable to create response")
            return
        }
        let output = outputFrom(response)
        XCTAssert(output?.token?.idToken != nil)
        XCTAssertTrue(response.isOkResult)
    }
    
    func test_carbonFootprintIdUseCase_withIdInputAndEmptyBotes_responseShouldBeFailed() {
        let nodeConfig = ["carbonFootprintShow": "[]"]
        let input = GetCarbonFootprintIdUseCaseInput(realmId: "HuellaCarbono")
        guard let response = executeGetCarbonFootprintIdUseCase(
            appconfig: nodeConfig,
            input: input
        ) else {
            XCTFail("unable to create response")
            return
        }
        XCTAssertTrue(response.isOkResult)
    }
    
    func test_carbonFootprintIdUseCase_withoutIdInput_responseShouldBeFailed() {
        let nodeConfig = ["carbonFootprintShow": "['013', '662', '655']"]
        let input = GetCarbonFootprintIdUseCaseInput(realmId: "")
        guard let response = executeGetCarbonFootprintIdUseCase(
            appconfig: nodeConfig,
            input: input
        ) else {
            XCTFail("unable to create response")
            return
        }
        XCTAssertTrue(response.isOkResult)
    }
}

private extension GetCarbonFootprintIdUseCaseTest {
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

    func executeGetCarbonFootprintIdUseCase(appconfig: [String: String]? = nil,
                                            input: GetCarbonFootprintIdUseCaseInput) -> UseCaseResponse<GetCarbonFootprintIdUseCaseOkOutput, StringErrorOutput>? {
        loadMockedData(appconfig: appconfig)
        let usecase = GetCarbonFootprintIdUseCase(dependenciesResolver: self.dependencies)
        guard let response = try? usecase.executeUseCase(requestValues: ()), response.isOkResult else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return response
    }
    
    func outputFrom(_ response: UseCaseResponse<GetCarbonFootprintIdUseCaseOkOutput, StringErrorOutput>) -> GetCarbonFootprintIdUseCaseOkOutput? {
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
        self.mockDataInjector.register(for: \.carbonFootprint.idToken, filename: "getCarbonFootprint_tokenId")
    }
}
