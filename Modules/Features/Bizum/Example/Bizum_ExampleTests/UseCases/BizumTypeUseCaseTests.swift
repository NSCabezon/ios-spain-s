import XCTest
import QuickSetup
import QuickSetupES
import UnitTestCommons
import CoreFoundationLib
import SANLibraryV3
import SANLegacyLibrary
import CoreTestData
@testable import Bizum

class BizumTypeUseCaseTests: XCTestCase {
    private let depdendecies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private let appconfigRepository: AppConfigRepositoryProtocol = MockAppConfigRepository(mockDataInjector: MockDataInjector(mockDataProvider: MockDataProvider()))
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        return QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }

    override func setUp() {
        self.depdendecies.register(for: AppConfigRepositoryProtocol.self, with: { _ in
            return self.appconfigRepository
        })
        self.depdendecies.register(for: BSANManagersProvider.self, with: { _ in
            return self.quickSetup.managersProvider
        })
        self.quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        self.quickSetup.doLogin(withUser: .demo)
    }
    
    override func tearDown() {
        self.quickSetup.setDemoAnswers([:])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: - Common
    
    func loadPG() {
        _ = self.quickSetup.getGlobalPosition()
    }
    
    func bizumTypeUseCase(answers: [String: Int], appconfig: [String: Any], type: BizumTypeUseCaseType) throws -> UseCaseResponse<BizumTypeUseCaseOkOutput, StringErrorOutput> {
        self.quickSetup.setDemoAnswers(answers)
        self.loadPG()
        let usecae = BizumTypeUseCase(dependenciesResolver: self.depdendecies)
        let input = BizumTypeUseCaseInput(type: type)
        let response = try usecae.executeUseCase(requestValues: input)
        return response
    }
    
    // MARK: - Tests
    
    func testBizumTypeUseCaseOkHome() {
        do {
            let response = try self.bizumTypeUseCase(answers: [:],
                                                     appconfig: ["enableBizumNative": true],
                                                     type: BizumTypeUseCaseType.home)
            guard response.isOkResult else {
                XCTFail("BizumTypeUseCase: Response is not ok")
                return
            }
            let data = try response.getOkResult()
            switch data {
            case .native:
                XCTAssert(true)
            case .web:
                XCTFail("BizumTypeUseCase: Response is succes with type web")
            }
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
    
    func testBizumTypeUseCaseOkSendMoney() {
        do {
            let response = try self.bizumTypeUseCase(answers: [:],
                                                     appconfig: ["enableSendMoneyBizumNative": true],
                                                     type: .send)
            guard response.isOkResult else {
                XCTFail("BizumTypeUseCase: Response is not ok")
                return
            }
            let data = try response.getOkResult()
            switch data {
            case .native:
                XCTAssert(true)
            case .web:
                XCTFail("BizumTypeUseCase: Response is succes with type web")
            }
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
    
    func test_bizum_type_useCaseOk_Cancel_notRegister() {
        do {
            let response = try self.bizumTypeUseCase(answers: [:],
                                                     appconfig: ["cancelSendMoneyForNotClientByBizum": true],
                                                     type: .cancelNotRegister)
            guard response.isOkResult else {
                XCTFail("BizumTypeUseCase: Response is not ok")
                return
            }
            let data = try response.getOkResult()
            switch data {
            case .native:
                XCTAssert(true)
            case .web:
                XCTFail("BizumTypeUseCase: Response is succes with type web")
            }
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
    
    func testBizumTypeUsecaseOkOtpExcepted() {
        do {
            let response = try self.bizumTypeUseCase(answers: ["consultaCMPS_LA": 5],
                                                     appconfig: ["enableBizumNative": true],
                                                     type: BizumTypeUseCaseType.home)
            guard response.isOkResult else {
                XCTFail("BizumTypeUseCase: Response is not ok")
                return
            }
            let data = try response.getOkResult()
            switch data {
            case .native:
                XCTFail("BizumTypeUseCase: Response is succes with type native")
            case .web:
                XCTAssert(true)
            }
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
    
    func testBizumTypeUsecaseOkConsultive() {
        do {
            let response = try self.bizumTypeUseCase(answers: ["consultarCMC_LA": 1],
                                                     appconfig: ["enableBizumNative": true],
                                                     type: BizumTypeUseCaseType.home)
            guard response.isOkResult else {
                XCTFail("BizumTypeUseCase: Response is not ok")
                return
            }
            let data = try response.getOkResult()
            switch data {
            case .native:
                XCTFail("BizumTypeUseCase: Response is succes with type native")
            case .web:
                XCTAssert(true)
            }
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
    
    func testBizumTypeUseCaseOkNoAppConfig() {
        do {
            let response = try self.bizumTypeUseCase(answers: [:],
                                                     appconfig: ["enableBizumNative": false],
                                                     type: BizumTypeUseCaseType.home)
            guard response.isOkResult else {
                XCTFail("BizumTypeUseCase: Response is not ok")
                return
            }
            let data = try response.getOkResult()
            switch data {
            case .native:
                XCTFail("BizumTypeUseCase: Response is succes with type native")
            case .web:
                XCTAssert(true)
            }
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
    
    func testBizumTypeUseCaseOkNoRegister() {
        do {
            let response = try self.bizumTypeUseCase(answers: ["check-payment": 1],
                                                     appconfig: ["enableBizumNative": true],
                                                     type: BizumTypeUseCaseType.home)
            guard response.isOkResult else {
                XCTFail("BizumTypeUseCase: Response is not ok")
                return
            }
            let data = try response.getOkResult()
            switch data {
            case .native:
                XCTFail("BizumTypeUseCase: Response is succes with type native")
            case .web:
                XCTAssert(true)
            }
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
    
    func testBizumTypeUseCaseError() {
        do {
            let response = try self.bizumTypeUseCase(answers: ["check-payment": 2],
                                                     appconfig: ["enableBizumNative": true],
                                                     type: BizumTypeUseCaseType.home)
            guard response.isOkResult == false else {
                XCTFail("BizumTypeUseCase: Response is ok")
                return
            }
            let data = try response.getErrorResult()
            XCTAssert(data.getErrorDesc() == "Se ha producido un error", "BizumTypeUseCase: Incorrect error description")
        } catch {
            XCTFail("BizumTypeUseCase: throw")
        }
    }
}
