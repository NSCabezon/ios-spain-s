import XCTest
import QuickSetup
import QuickSetupES
import Operative
import CoreFoundationLib
import SANLibraryV3
import CoreTestData
@testable import Bizum
@testable import Bizum_Example

class BizumSimpleAmountUseCaseTests: XCTestCase {
    private let dependenciesResolver =  DependenciesDefault()
    private let appConfigRepository = BizumAppConfigRepositoryMock()
    private let useCaseHandler: UseCaseHandler = UseCaseHandler()
    private var sut: BizumValidateMoneyTransferUseCase?
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }
    
    override func setUp() {
        self.dependenciesResolver.register(for: AppConfigRepositoryProtocol.self, with: { _ in
            return self.appConfigRepository
        })
        self.dependenciesResolver.register(for: BSANManagersProvider.self, with: { _ in
            return self.quickSetup.managersProvider
        })
        self.dependenciesResolver.register(for: UseCaseHandler.self, with: { _ in
            return self.useCaseHandler
        })
        self.appConfigRepository.setConfiguration([BizumHomeConstants.bizumDefaultXPAN: "9724020250000001"])
        self.quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        self.quickSetup.doLogin(withUser: .demo)
        self.sut = BizumValidateMoneyTransferUseCase(dependencies: dependenciesResolver)
    }

    override func tearDown() {
        self.appConfigRepository.setConfiguration([:])
        self.quickSetup.setDemoAnswers([:])

    }

    func testSimpleAmountUseCase_ShouldResponseOK() {
        self.quickSetup.setDemoAnswers(["validate-money-transfer": 0])
        let expect = expectation(description: "Simple sending is success")
        guard let input = self.generateSimpleSendMoneyInput(),
            let response = try? self.sut?.executeUseCase(requestValues: input), response.isOkResult else {
                return  XCTFail("validate-money-transfer: Response is not ok")
        }
        expect.fulfill()
        waitForExpectations(timeout: 5, handler: .none)
    }

    func testSimpleAmountUseCase_ShouldResponseUserNoRegistered() {
        quickSetup.setDemoAnswers(["validate-money-transfer": 1])
        let expect = expectation(description: "User is not registered in Bizum")
        guard let input = self.generateSimpleSendMoneyInput(),
            let response = try? self.sut?.executeUseCase(requestValues: input), response.isOkResult,
            let data = try? response.getOkResult() else {
                return  XCTFail("validate-money-transfer: Response is not ok")
        }
        if !data.userRegistered {
            expect.fulfill()
        }
        waitForExpectations(timeout: 5, handler: .none)
    }

    private func generateSimpleSendMoneyInput() -> BizumSimpleSendMoneyInputUseCase? {
        let bsanManager: BSANManagersProvider = dependenciesResolver.resolve()
        let bsanBizumManager = bsanManager.getBSANBizumManager()
        let bsanPersonalDataManager = bsanManager.getBsanPersonDataManager()
        let xpan = appConfigRepository.getString(BizumHomeConstants.bizumDefaultXPAN) ?? ""
        guard let checkPayment = try? bsanBizumManager.checkPayment(defaultXPAN: xpan),
              let bizumCheckPaymentDTO = try? checkPayment.getResponseData(),
            let personalInformationResponse = try? bsanPersonalDataManager.loadBasicPersonData(),
            let personBasicDataDTO = try? personalInformationResponse.getResponseData() else {
                return nil
        }
        let entity = BizumCheckPaymentEntity(bizumCheckPaymentDTO)
        let input = BizumSimpleSendMoneyInputUseCase(checkPayment: entity, document: BizumDocumentEntity(personBasicData: personBasicDataDTO), concept: "", amount: "", receiverUserId: "", account: nil)
        return input
    }
}
