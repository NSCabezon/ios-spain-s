//
//  BizumDetailPresenterTests.swift
//  Bizum_ExampleTests
//
//  Created by Jose Ignacio de Juan Díaz on 16/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import UnitTestCommons
import QuickSetup
@testable import Bizum
@testable import SANLibraryV3
@testable import SANLegacyLibrary

class BizumDetailPresenterTests: XCTestCase {
    private let dependecies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private let view: BizumDetailViewMock = BizumDetailViewMock()
    private var presenter: BizumDetailPresenterProtocol?
    
    override func setUp() {
        dependecies.register(for: BizumDetailViewProtocol.self, with: { _ in
            return self.view
        })
        self.dependecies.register(for: TimeManager.self, with: { _ in
            return TimeManagerMock()
        })
        self.dependecies.register(for: TrackerManager.self, with: { _ in
            return TrackerManagerMock()
        })
        self.dependecies.register(for: BizumCheckPaymentConfiguration.self, with: { _ in
            return BizumCheckPaymentConfiguration(bizumCheckPaymentEntity: self.getBizumCheckPayment())
        })
        self.dependecies.register(for: BizumActionsAppConfigUseCase.self) { resolver in
            return BizumActionsAppConfigUseCase(dependenciesResolver: resolver)
        }
        self.dependecies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return AppConfigRepositoryMock()
        }
        self.dependecies.register(for: DetailModuleCoordinatorProtocol.self, with: { _ in
            return DetailModuleCoodinatorMock()
        })
        self.dependecies.register(for: UseCaseScheduler.self) { _ in
            return DispatchQueue.main
        }
        presenter = BizumDetailPresenter(dependenciesResolver: dependecies,
                                    detail: getSimpleBizumHistoricOperationEntity())
        presenter?.view = view
    }
    
    override func tearDown() {
        view.tearDown()
    }
    
    func getBizumCheckPayment() -> BizumCheckPaymentEntity {
        let centerDTO = CentroDTO(empresa: "",
                                  centro: "")
        let bizumCheckPaymentContractDTO = BizumCheckPaymentContractDTO(center: centerDTO,
                                                                        subGroup: "",
                                                                        contractNumber: "")
        let ibanDTO = BizumCheckPaymentIBANDTO(country: "",
                                               controlDigit: "",
                                               codbban: "")
        let bizumCheckPaymentDTO = BizumCheckPaymentDTO(phone: "+34625312027",
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
    
    func getSimpleBizumHistoricOperationEntity() -> BizumHistoricOperationEntity {
        let ibanEmissorDTO = BizumIbanDTO(country: "",
                                   checkDigits: "",
                                   codbban: "")
        let ibanReceptorDTO = BizumIbanDTO(country: "ES",
                                   checkDigits: "19",
                                   codbban: "ES1900490075462116810385      ")
        let fieldA = BizumOperationField(field: "CONTENIDO_ADICIONAL", value: "0")
        let fieldB = BizumOperationField(field: "IND_MULTIPLE", value: "0")
        let fieldC = BizumOperationField(field: "IND_ONG", value: "0")
        let listField = BizumOperationListField(fields: [fieldA, fieldB, fieldC])
        let operationDTO = BizumOperationDTO(operationId: "43970559752235037915353460356246465",
                                             emitterId: "+34625312027",
                                             receptorId: "+34722568844",
                                             emitterIban: ibanEmissorDTO,
                                             receptorIban: ibanReceptorDTO,
                                             type: "C2CPush",
                                             amount: 23.45,
                                             concept: "MyConcept",
                                             dischargeDate: Date(),
                                             modificationDate: Date(),
                                             state: "PENDIENTEA",
                                             emitterAlias: "Estela Isabel D. A.",
                                             receptorAlias: "Paco P. B.",
                                             returnedFields: listField)
        let operationEntity  = BizumOperationEntity(operationDTO)
        return BizumHistoricOperationEntity.simple(operation: operationEntity)
    }
    
    func testViewDidLoad() {
        presenter?.viewDidLoad()
        let items = view.showItems
        items.forEach { (detailItem) in
            switch detailItem {
            case .amount(let item):
                XCTAssertTrue(String(item.amountWithAttributed?.string ?? "") == "−23,45€")
            case .origin(let item):
                let title = "bizumDetail_label_sendType"
                XCTAssertTrue(item.title.text == title)
            case .multimedia:
                break
            case .recipients(let items, let title):
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(title.text, "bizumDetail_label_destination")
            case .actions(let items):
                XCTAssertEqual(items.count, 1)
            case .transferType(let item):
                let typeTransaction = "bizumDetail_label_bizumNoCommissions"
                XCTAssertTrue(item.value?.text == typeTransaction)
            }
        }
    }
    
    func testShowImage() {
        presenter?.showImage()
        var detailModuleCoordinator: DetailModuleCoordinatorProtocol {
            self.dependecies.resolve(for: DetailModuleCoordinatorProtocol.self)
        }
        guard let coordinator = detailModuleCoordinator as? DetailModuleCoodinatorMock else {
            XCTFail("Failed casting mocked coordinator")
            return
        }
        XCTAssertFalse(coordinator.hasOpenImage)
    }
}

class BizumDetailViewMock {
    var associatedLoadingView =  UIViewController()
    var showItems: [BizumDetailItemsViewModel] = []
    var showMultimediaItems: [MultimediaType] = []
    var isShowingFeatureNotAvailable = false
    
    func tearDown() {
        showItems = []
        showMultimediaItems = []
        isShowingFeatureNotAvailable = false
    }
    
}

extension BizumDetailViewMock: BizumDetailViewProtocol {
    func didTapShare(_ viewModel: ShareBizumDetailViewModel) {
        
    }
    
    func showDetail(_ items: [BizumDetailItemsViewModel]) {
        showItems = items
    }
    
    func showMultimedia(_ viewModels: [MultimediaType]) {
        showMultimediaItems = viewModels
    }
    
    func showFeatureNotAvailableToast() {
        isShowingFeatureNotAvailable = true
    }
}

class DetailModuleCoodinatorMock: DetailModuleCoordinatorProtocol {
    
    var hasDismiss = false
    var hasOpenImage = false
    var hasOpenReuseContact = false
    
    func tearDown() {
        hasDismiss = false
        hasOpenImage = false
    }
    
    func didSelectDismiss() {
        hasDismiss = true
    }
    
    func openImageDetail(_ image: Data) {
        hasOpenImage = true
    }
    func didSelectReuseContact(_ contacts: [BizumContactEntity]) {
        hasOpenReuseContact = true
    }
    
    func didSelectAcceptRequest(_ entity: BizumHistoricOperationEntity) {
        
    }
    
    func didSelectRejectRequest(_ entity: BizumHistoricOperationEntity) {
        
    }
    
    func didSelectCancelRequest(_ entity: BizumHistoricOperationEntity) {
        
    }
    
    func didSelectRejectSend(_ entity: BizumHistoricOperationEntity) {
        
    }
    
    func sendAgainViewDisappear() {
        
    }

    func didSelectCancelNotRegistered(_ operationEntity: BizumHistoricOperationEntity) {
        
    }
    
    func didSelectRefund(_ entity: BizumHistoricOperationEntity) {
        
    }
    
    func didSelectSendAgain(_ type: BizumEmitterType, contact: BizumContactEntity, sendMoney: BizumSendMoney, items: [BizumDetailItemsViewModel]) {
        
    }
}
