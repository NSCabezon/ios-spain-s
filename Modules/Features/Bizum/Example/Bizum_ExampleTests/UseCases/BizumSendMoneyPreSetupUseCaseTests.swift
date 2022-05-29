import XCTest
import QuickSetup
import QuickSetupES
import CoreFoundationLib
@testable import SANLibraryV3
@testable import Bizum
@testable import SANLegacyLibrary

class BizumCommonPreSetupUseCaseTests: XCTestCase {
    private let dependenciesResolver =  DependenciesDefault()
    private var globalPosition: GlobalPositionRepresentable?
    var quickSetup: QuickSetupES.QuickSetupForSpainLibrary {
        QuickSetupForSpainLibrary(environment: QuickSetupES.BSANEnvironments.environmentPre, user: .demo)
    }

    override func setUp() {
        self.setupDependencies()
        self.quickSetup.doLogin(withUser: .demo)
        self.globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
    }

    override func tearDown() {
        self.globalPosition = nil
    }

    func testSendMoneyPreSetupShouldAccountExist() {
        let checkPayment = getBizumCheckPaymentAccountExist()
        let input = BizumCommonPreSetupUseCaseInput(bizumCheckPaymentEntity: checkPayment, operationEntity: nil)
        let useCase = BizumCommonPreSetupUseCase(dependenciesResolver: dependenciesResolver)
        guard
            let response = try? useCase.executeUseCase(requestValues: input), response.isOkResult,
            let data = try? response.getOkResult() else {
                XCTFail("BizumCommonPreSetupUseCase: Response is not ok")
                return
        }
        XCTAssert(checkPayment.dto.ibanCode.codbban == data.account.dto.iban?.codBban)
    }

    func testSendMoneyPreSetupShouldAccountDoesNotExist() {
        let checkPayment = getBizumCheckPaymentAccountDoesNotExist()
        let input = BizumCommonPreSetupUseCaseInput(bizumCheckPaymentEntity: checkPayment, operationEntity: nil)
        let useCase = BizumCommonPreSetupUseCase(dependenciesResolver: dependenciesResolver)
        guard
            let response = try? useCase.executeUseCase(requestValues: input), response.isOkResult,
            ((try? response.getOkResult()) != nil)
        else {
            XCTAssertNotNil("Account doesn't exist")
            return
        }
        XCTFail("BizumCommonPreSetupUseCase: Response is not ok")
    }

    func getBizumCheckPaymentAccountExist() -> BizumCheckPaymentEntity {
        let centerDTO = CentroDTO(empresa: "0086",
                                  centro: "3231")
        let bizumCheckPaymentContractDTO = BizumCheckPaymentContractDTO(center: centerDTO,
                                                                        subGroup: "764",
                                                                        contractNumber: "0001648")
        let ibanDTO = BizumCheckPaymentIBANDTO(country: "ES",
                                               controlDigit: "90",
                                               codbban: "00863231950010200141")
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

    func getBizumCheckPaymentAccountDoesNotExist() -> BizumCheckPaymentEntity {
        let centerDTO = CentroDTO(empresa: "0017",
                                  centro: "0049")
        let bizumCheckPaymentContractDTO = BizumCheckPaymentContractDTO(center: centerDTO,
                                                                        subGroup: "764",
                                                                        contractNumber: "0001648")
        let ibanDTO = BizumCheckPaymentIBANDTO(country: "ES",
                                               controlDigit: "90",
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
}

// MARK: - private extension
private extension BizumCommonPreSetupUseCaseTests {
    func setupDependencies() {
        self.dependenciesResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        self.dependenciesResolver.register(for: AppConfigRepositoryProtocol.self) { _ in
            return AppConfigRepositoryMock()
        }
        self.dependenciesResolver.register(for: GlobalPositionRepresentable.self) { _ in
            guard let globalPosition = self.globalPosition else {
                self.globalPosition = self.quickSetup.getGlobalPosition()
                return self.globalPosition!
            }
            return globalPosition
        }
        self.dependenciesResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            return merger
        }
        self.dependenciesResolver.register(for: BSANManagersProvider.self) { _ in
            self.quickSetup.managersProvider
        }
    }
}
