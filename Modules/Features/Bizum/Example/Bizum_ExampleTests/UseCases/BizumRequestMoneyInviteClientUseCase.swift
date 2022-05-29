import XCTest
import QuickSetup
import QuickSetupES
import Operative
import CoreFoundationLib
import SANLibraryV3
@testable import Bizum

class BizumRequestMoneyInviteClientUseCaseTests: XCTestCase {
    private let dependenciesResolver =  DependenciesDefault()
    private let appConfigRepository: AppConfigRepositoryMock = AppConfigRepositoryMock()
    private var sut: BizumRequestMoneyInviteClientUseCase?
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
        quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
        self.sut = BizumRequestMoneyInviteClientUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    override func tearDown() {
        self.quickSetup.setDemoAnswers([:])
    }

    func loadPG() {
        _ = quickSetup.getGlobalPosition()
    }

    func testBizumRequestMoneyInviteUseCaseShouldResponseSuccess() {
        quickSetup.setDemoAnswers(["invite-no-client": 0])
        guard let input = generateInviteUseCaseInput(concept: "", amount: "", receiverUserId: ""),
            let response = try? self.sut?.executeUseCase(requestValues: input),
            response.isOkResult else {
                return XCTFail("RequestMoneyInviteUseCase: Response is not ok")
        }
        assert(true)
    }

    func testBizumRequestMoneyInviteUseCaseShouldResponseFailure() {
        quickSetup.setDemoAnswers(["invite-no-client": 10])
        guard let input = generateInviteUseCaseInput(concept: "", amount: "", receiverUserId: ""),
            let response = try? self.sut?.executeUseCase(requestValues: input),
            !response.isOkResult else {
                return XCTFail("RequestMoneyInviteUseCase: Response is ok")
        }
        assert(true)
    }

    private func generateInviteUseCaseInput(concept: String, amount: String, receiverUserId: String) -> BizumRequestMoneyInviteClientUseCaseInput? {
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
        let input = BizumValidateMoneyRequestInputParams(checkPayment: bizumCheckPaymentDTO,
                                                         document: BizumDocumentEntity(personBasicData: personBasicDataDTO).dto,
                                                     dateTime: Date(),
                                                     concept: concept,
                                                     amount: amount,
                                                     receiverUserId: receiverUserId)
        guard let validateMoneyRequestDTO = try? bsanBizumManager.validateMoneyRequest(input).getResponseData() else { return nil }
        let entity = BizumValidateMoneyRequestEntity(validateMoneyRequestDTO)
        let useCaseInput = BizumRequestMoneyInviteClientUseCaseInput(validateMoneyRequestEntity: entity)
        return useCaseInput
    }
}
