//
//  ConfirmationViewControllerTests.swift
//  Bizum_ExampleTests
//
//  Created by Margaret López Calderón on 23/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SnapshotTesting
import UnitTestCommons
import QuickSetup
import Operative
import Localization
@testable import CoreFoundationLib
@testable import Bizum
@testable import SANLegacyLibrary

final class ConfirmationViewControllerTests: XCTestCase {
    var viewController: BizumConfirmationViewController!
    var presenter: BizumConfirmationPresenterMock!
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()

    private lazy var localeManager: LocaleManager = {
        let locale = LocaleManager(dependencies: dependencies)
        locale.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        return locale
    }()

    override func setUpWithError() throws {
        self.setupDependencies()
        self.presenter = BizumConfirmationPresenterMock(dependenciesResolver: self.dependencies)
        self.viewController = BizumConfirmationViewController(presenter: presenter)
        self.presenter.view = self.viewController
    }

    override func tearDownWithError() throws {
        self.viewController = nil
    }

    func testBizumConfirmationRequestMoney_withEmptyConcept() throws {
        let data = BizumSendMoneyOperativeDataMock(type: .request)
            .addAmountAndConcept(amount: 30.0, concept: "")
        self.presenter.operativeDataMock = data
        let builder = BizumRequestMoneyConfirmationBuilder(data: data.generateOperativeData() as? BizumRequestMoneyOperativeData ?? data.requestMoneyOperativeData,
                                                           dependenciesResolver: self.dependencies)
        builder.addAmountAndConcept(action: {})
        builder.addMedia()
        builder.addContacts(action: {})
        builder.addTotal()
        self.viewController.add(builder.build())
        assertSnapshot(matching: self.viewController, as: .image(on: .iPhone8))
    }

    func testBizumConfirmationSendMoney_withMultimedia() throws {
        let data = BizumSendMoneyOperativeDataMock(type: .send)
            .addAmountAndConcept(amount: 20.0, concept: "pizzas")
            .addMultimedia(image: getImage(), note: "Send")
        self.presenter.operativeDataMock = data
        let builder = BizumSendMoneyConfirmationBuilder(data: data.generateOperativeData() as? BizumSendMoneyOperativeData ?? data.sendMoneyOperativeData,
                                                        dependenciesResolver: self.dependencies)
        builder.addAmountAndConcept(action: {})
        builder.addMedia()
        builder.addOriginAccount(action: {})
        builder.addTransferType()
        builder.addContacts(action: {})
        builder.addTotal()
        self.viewController.add(builder.build())
        assertSnapshot(matching: self.viewController, as: .image(on: .iPhone8))
    }
}
private extension ConfirmationViewControllerTests {
    func setupDependencies() {
        self.dependencies.register(for: StringLoader.self) { _ in
            return self.localeManager
        }
        self.dependencies.register(for: LocalAppConfig.self) { _ in
            return LocalAppConfigMock()
        }
                    
        self.dependencies.register(for: GetLanguagesSelectionUseCaseProtocol.self) { _ in
            return GetLanguagesSelectionUseCase(dependencies: self.dependencies)
        }
        
        self.dependencies.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        
        self.dependencies.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }

        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return AppConfigRepositoryMock()
        }
        Localized.shared.setup(dependenciesResolver: self.dependencies)
    }

    func getImage() -> Data? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "gift.fill")?.pngData()
        } else {
            return nil
        }
    }
}

final class BizumConfirmationPresenterMock: BizumConfirmationPresenterProtocol {
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false

    var container: OperativeContainerProtocol?
    var view: BizumConfirmationViewProtocol?
    var dependenciesResolver: DependenciesResolver
    var operativeDataMock: BizumSendMoneyOperativeDataMock?

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    func viewDidLoad() {}

    func didTapClose() {}

    func getContacts() {
        let data = BizumSendMoneyOperativeDataMock(type: .request)
            .addAmountAndConcept(amount: 30.0, concept: "")
        guard let operativeDataMock = operativeDataMock else { return }
        self.view?.setContacts(operativeDataMock.getContacts() ?? [data.requestConfirmationDetail])
    }

    func didSelectBiometricValidationButton() {}

    func didSelectContinue() { }
}

enum TypeOperation {
    case request
    case send
    case unknown
}

final class BizumSendMoneyOperativeDataMock {
    private var bizumCheckPaymentEntity: BizumCheckPaymentEntity {
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
    let requestConfirmationDetail = ConfirmationContactDetailViewModel(identifier: "+34625312027",
                                                                       name: "Estela",
                                                                       alias: "Estela Isabel D. A",
                                                                       initials: "EI",
                                                                       phone: "625 312 027",
                                                                       amount: nil,
                                                                       validateSendAction: "Enviar",
                                                                       colorModel:ColorsByNameViewModel(.eighth),
                                                                       thumbnailData: nil)

    let sendConfirmationDetail = ConfirmationContactDetailViewModel(identifier: "+34625312027",
                                                                    name: "Estela",
                                                                    alias: "Estela Isabel D. A",
                                                                    initials: "EI",
                                                                    phone: "625 312 027",
                                                                    amount: nil,
                                                                    validateSendAction: "Solicitar",
                                                                    colorModel: ColorsByNameViewModel(.eighth),
                                                                    thumbnailData: nil)
    var sendMoneyOperativeData: BizumSendMoneyOperativeData {
        let operativeData = BizumSendMoneyOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity)
        operativeData.typeUserInSimpleSend = .register
        operativeData.accountEntity = nil
        operativeData.accounts = []
        operativeData.bizumContactEntity = []
        operativeData.bizumSendMoney = bizumSendMoney
        operativeData.multimediaData = multimediaData
        operativeData.simpleMultipleType = .simple
        return operativeData as BizumSendMoneyOperativeData
    }
    
    var requestMoneyOperativeData: BizumRequestMoneyOperativeData {
        let operativeData = BizumRequestMoneyOperativeData(bizumCheckPaymentEntity: bizumCheckPaymentEntity)
        operativeData.typeUserInSimpleSend = .register
        operativeData.accountEntity = nil
        operativeData.accounts = []
        operativeData.bizumContactEntity = []
        operativeData.bizumSendMoney = bizumSendMoney
        operativeData.multimediaData = multimediaData
        operativeData.simpleMultipleType = .simple
        return operativeData as BizumRequestMoneyOperativeData
    }
    
    private var amount: AmountEntity?
    private var bizumSendMoney: BizumSendMoney?
    private var multimediaData: BizumMultimediaData?
    private let type: TypeOperation

    init(type: TypeOperation) {
        self.type = type
    }

    func addAmountAndConcept(amount: Decimal, concept: String) -> Self {
        let amount = AmountEntity(value: amount)
        self.amount = amount
        self.bizumSendMoney = BizumSendMoney(amount: amount, totalAmount: amount, concept: concept)
        return self
    }

    func addMultimedia(image: Data?, note: String?) -> Self {
        self.multimediaData = BizumMultimediaData(image: image, note: note)
        return self
    }

    func generateOperativeData() -> BizumMoneyOperativeData? {
        switch self.type {
        case .request:
            return requestMoneyOperativeData
        case .send:
            return sendMoneyOperativeData
        case .unknown:
            return nil
        }
    }

    func getContacts() -> [ConfirmationContactDetailViewModel]? {
        switch type {
        case .request:
            return [
                requestConfirmationDetail
            ]
        case .send:
            return [
                sendConfirmationDetail
            ]
        case .unknown:
            return nil
        }
    }
}
