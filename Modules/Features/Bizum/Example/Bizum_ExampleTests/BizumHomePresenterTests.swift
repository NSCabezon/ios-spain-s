import XCTest
import QuickSetup
import QuickSetupES
import UnitTestCommons
@testable import Bizum
@testable import Bizum_Example
@testable import SANLibraryV3
@testable import SANLegacyLibrary
@testable import CoreFoundationLib

class BizumHomePresenterTests: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private let view: BizumHomeViewMock = BizumHomeViewMock()
    private var presenter: BizumHomePresenterProtocol?
    private let reloadEngine: GlobalPositionReloadEngine = GlobalPositionReloadEngine()
    private let usecaseHandler: UseCaseHandler = UseCaseHandler()
    private let bizumHomeConfigurationUseCaseMock: BizumHomeConfigurationUseCaseMock = BizumHomeConfigurationUseCaseMock()
    private let bizumOperationUseCaseMock: BizumOperationUseCaseMock = BizumOperationUseCaseMock()
    private let appConfigRepository = BizumAppConfigRepositoryMock()
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }
    
    override func setUp() {
        quickSetup.doLogin(withUser: .demo)
        self.dependencies.register(for: BizumHomeViewProtocol.self, with: { _ in
            return self.view
        })
        self.dependencies.register(for: GlobalPositionReloadEngine.self, with: { _ in
            return self.reloadEngine
        })
        self.dependencies.register(for: UseCaseHandler.self, with: { _ in
            return self.usecaseHandler
        })
        self.dependencies.register(for: GetFaqsUseCaseAlias.self, with: { _ in
            return GetFaqsUseCaseMock()
        })
        self.dependencies.register(for: ColorsByNameEngine.self, with: { _ in
            return ColorsByNameEngine()
        })
        self.dependencies.register(for: BizumHomeConfigurationUseCaseAlias .self, with: { _ in
            return self.bizumHomeConfigurationUseCaseMock
        })
        self.dependencies.register(for: BizumOperationUseCaseAlias.self, with: { _ in
            return self.bizumOperationUseCaseMock
        })
        self.dependencies.register(for: TimeManager.self, with: { _ in
            return TimeManagerMock()
        })
        self.dependencies.register(for: AppConfigRepositoryProtocol.self, with: { _ in
            return self.appConfigRepository
        })
        self.dependencies.register(for: GetPullOffersUseCase.self) { resolver in
            return GetPullOffersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            return self.quickSetup.getGlobalPosition()!
        }
        self.dependencies.register(for: PullOffersInterpreter.self, with: { _ in
            return Bizum_Example.PullOffersInterpreterMock()
        })
        self.presenter = BizumHomePresenter(dependenciesResolver: self.dependencies,
                                            bizumCheckPaymentEntity: self.getBizumCheckPayment())
        self.appConfigRepository.setConfiguration([BizumHomeConstants.bizumDefaultXPAN: "9724020250000001"])
        self.presenter?.view = self.view
    }
    
    override func tearDown() {
        self.view.tearDown()
        self.bizumHomeConfigurationUseCaseMock.isEnableSendMoneyBizumNative = nil
        self.bizumOperationUseCaseMock.response = nil
        self.appConfigRepository.setConfiguration([:])
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
    
    // MARK: - Tests
    
    func testRecentsLoading() {
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: BizumHomeViewMock = view as? BizumHomeViewMock else {
                return false
            }
            return view.isRecentsLoading == true
        }
        _ = self.expectation(for: predicate, evaluatedWith: self.view, handler: .none)
        self.presenter?.viewDidLoad()
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    func testContacsNotLoading() {
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: BizumHomeViewMock = view as? BizumHomeViewMock else {
                return false
            }
            return view.isContacsLoading != true
        }
        _ = self.expectation(for: predicate, evaluatedWith: self.view, handler: .none)
        self.presenter?.viewDidLoad()
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    func testContacsLoading() {
        self.bizumHomeConfigurationUseCaseMock.isEnableSendMoneyBizumNative = true
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: BizumHomeViewMock = view as? BizumHomeViewMock else {
                return false
            }
            return view.isContacsLoading == true
        }
        _ = self.expectation(for: predicate, evaluatedWith: self.view, handler: .none)
        self.presenter?.viewDidLoad()
        waitForExpectations(timeout: 5, handler: .none)
    }
}

class BizumHomeViewMock {
    var isRecentsEmptyView: Bool?
    var isRecentsLoading: Bool?
    var recentsItems: [BizumHomeOperationViewModel]?
    var isContacsLoading: Bool?
    var isContactsEmpty: Bool?
    var contactsItems: [BizumHomeContactViewModel]?
    var faqsItems: [FaqsViewModel]?
    var optionsItems: [BizumHomeOptionViewModel]?
    var isShowDialogPermissions: Bool?
    var isShowAlertContactList: Bool?
    
    func tearDown() {
        self.isRecentsEmptyView = nil
        self.isRecentsLoading = nil
        self.recentsItems = nil
        self.isContactsEmpty = nil
        self.contactsItems = nil
        self.faqsItems = nil
        self.optionsItems = nil
        self.isShowDialogPermissions = nil
        self.isShowAlertContactList = nil
    }
}

extension BizumHomeViewMock: BizumHomeViewProtocol {
    func disableGoToHistoric(_ disable: Bool) {
        
    }
    
    func showBizumShoppingAlert() {
        
    }
    
    func setRecentsEmptyView() {
        self.isRecentsEmptyView = true
    }
    
    func setRecentsLoading() {
        self.isRecentsLoading = true
    }
    
    func setRecents(_ items: [BizumHomeOperationViewModel]) {
        self.recentsItems = items
    }
    
    func setContactsLoading() {
        self.isContacsLoading = true
    }
    
    func setContactsEmpty() {
        self.isContactsEmpty = true
    }
    
    func setContacts(_ items: [BizumHomeContactViewModel]) {
        self.contactsItems = items
    }
    
    func showFaqs(_ viewModels: [FaqsViewModel]) {
        self.faqsItems = viewModels
    }
    
    func showFeatureNotAvailableToast() {}
    
    func setOptions(_ items: [BizumHomeOptionViewModel]) {
        self.optionsItems = items
    }
    
    func showDialogPermission() {
        self.isShowDialogPermissions = true
    }
    
    func showAlertContactList() {
        self.isShowAlertContactList = true
    }
    
    func showContacts(with: ContactListPresenter) {}
}

class BizumHomeConfigurationUseCaseMock: BizumHomeConfigurationUseCaseAlias {
    var isEnableSendMoneyBizumNative: Bool?
    var isEnableBizumQrOption: Bool = true

    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<BizumHomeConfigurationUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(BizumHomeConfigurationUseCaseOkOutput(isEnableSendMoneyBizumNative: self.isEnableSendMoneyBizumNative == true,
                                                                        isEnableBizumQrOption: self.isEnableBizumQrOption))
    }
}

enum BizumOperationUseCaseMockResponse {
    case error(error: String?)
    case success(data: [BizumOperationEntity])
}

class BizumOperationUseCaseMock: BizumOperationUseCaseAlias {
    var response: BizumOperationUseCaseMockResponse?
    
    override init() {}
    
    override func executeUseCase(requestValues: BizumOperationUseCaseInput) throws -> UseCaseResponse<BizumOperationUseCaseOkOutput, StringErrorOutput> {
        switch response {
        case .error(let error):
            return UseCaseResponse.error(StringErrorOutput(error))
        case .success(let data):
            return UseCaseResponse.ok(BizumOperationUseCaseOkOutput(operations: data,
                                                                    isMoreData: false,
                                                                    totalPages: 1))
        case .none:
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
    }
}

class GetFaqsUseCaseMock: GetFaqsUseCaseAlias {
    override func executeUseCase(requestValues: FaqsUseCaseInput) throws -> UseCaseResponse<FaqsUseCaseOutput, StringErrorOutput> {
        return UseCaseResponse.ok(FaqsUseCaseOutput(faqs: [], showVirtualAssistant: false))
    }
}
