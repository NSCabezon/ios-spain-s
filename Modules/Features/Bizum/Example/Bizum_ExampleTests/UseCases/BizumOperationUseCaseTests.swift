import XCTest
import QuickSetup
import QuickSetupES
import UnitTestCommons
import CoreFoundationLib
@testable import Bizum
@testable import SANLibraryV3
@testable import SANLegacyLibrary

class BizumOperationUseCaseTests: XCTestCase {
    private let depdendecies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }

    override func setUp() {
        self.depdendecies.register(for: BSANManagersProvider.self, with: { _ in
            return self.quickSetup.managersProvider
        })
        quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
        _ = quickSetup.getGlobalPosition()
    }
    
    override func tearDown() {
        quickSetup.setDemoAnswers([:])
    }
    
    // MARK: - Common
    
    func getBizumCheckPayment() -> BizumCheckPaymentEntity {
        let centerDTO = CentroDTO(empresa: "",
                                  centro: "")
        let bizumCheckPaymentContractDTO = BizumCheckPaymentContractDTO(center: centerDTO,
                                                                        subGroup: "",
                                                                        contractNumber: "")
        let ibanDTO = BizumCheckPaymentIBANDTO(country: "",
                                               controlDigit: "",
                                               codbban: "")
        let bizumCheckPaymentDTO = BizumCheckPaymentDTO(phone: "",
                                                        contractIdentifier: bizumCheckPaymentContractDTO,
                                                        initialDate: Date(),
                                                        endDate: Date(),
                                                        back: nil,
                                                        message: nil, ibanCode: ibanDTO,
                                                        offset: nil,
                                                        offsetState: nil,
                                                        indMigrad: "",
                                                        xpan: "")
        return BizumCheckPaymentEntity(bizumCheckPaymentDTO)
    }
    
    func usecase(answers: [String: Int]) throws -> UseCaseResponse<BizumOperationUseCaseOkOutput, StringErrorOutput> {
        quickSetup.setDemoAnswers(answers)
        let usecae = BizumOperationUseCase(dependenciesResolver: self.depdendecies)
        let input = BizumOperationUseCaseInput(page: 0,
                                               checkPayment: self.getBizumCheckPayment(),
                                               orderBy: nil,
                                               orderType: nil)
        let response = try usecae.executeUseCase(requestValues: input)
        return response
    }
    
    // MARK: - Tests
    
    func testOkResponse() {
        do {
            let response = try self.usecase(answers: [:])
            guard response.isOkResult else {
                XCTFail("BizumOperationUseCase: Response is not ok")
                return
            }
            _ = try response.getOkResult()
            XCTAssert(true)
        } catch {
            XCTFail("BizumOperationUseCase: throw")
        }
    }
    
    func testFailResponse() {
        do {
            let response = try self.usecase(answers: ["multi-filter-query": 1])
            guard response.isOkResult == false else {
                XCTFail("BizumOperationUseCase: Response is ok")
                return
            }
            let data = try response.getErrorResult()
            XCTAssert(data.getErrorDesc() == "Se ha producido un error", "BizumOperationUseCase: Incorrect error description")
        } catch {
            XCTFail("BizumOperationUseCase: throw")
        }
    }
}
