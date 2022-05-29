import CoreFoundationLib
import XCTest
import QuickSetup
@testable import Bizum

class BizumSendAgainBuilderTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private var sut: BizumSendAgainBuilder?

    override func setUp() {
        self.dependencies.register(for: TrackerManager.self, with: { _ in
            return TrackerManagerMock()
        })
    }

    func testBuilderForSendShouldGenerateSixItems() {
        self.generateBizumSendAgainConfiguration(type: .send)
        self.sut = BizumSendAgainBuilder(configuration: dependencies.resolve())
            .addTitle()
            .addItems()
            .addContact()
            .addContinueButton()
        let items = self.sut?.items
        XCTAssert(items?.count == 6)
    }

    func testBuilderForRequestShouldGenerateFourItems() {
        self.generateBizumSendAgainConfiguration(type: .request)
        self.sut = BizumSendAgainBuilder(configuration: dependencies.resolve())
            .addTitle()
            .addItems()
            .addContact()
            .addContinueButton()
        let items = self.sut?.items
        XCTAssert(items?.count == 4)
    }
}

private extension BizumSendAgainBuilderTest {
    func generateBizumSendAgainConfiguration(type: BizumEmitterType) {
        let contact = BizumContactEntity(identifier: "+34625312027", name: "Estela Isabel D. A.", phone: "+34625312027", alias: "Estela Isabel D. A.")
        let sendMoney = BizumSendMoney(amount: AmountEntity(value: Decimal(23.0)), totalAmount: AmountEntity(value: Decimal(23.0)))
        self.dependencies.register(for: BizumSendAgainConfiguration.self) { _ in
            return BizumSendAgainConfiguration(type, contact: contact, sendMoney: sendMoney, items: self.generateItemFromSend())
        }
    }

    func generateItemFromSend() -> [BizumDetailItemsViewModel] {
        return [BizumDetailItemsViewModel.amount(ItemDetailAmountViewModel(title: TextWithAccessibility(text: "Importe"),
                                                                           amount: AmountEntity(value: Decimal(0.0)),
                                                                           info: TextWithAccessibility(text: "prueba"))),
                BizumDetailItemsViewModel.origin(ItemDetailViewModel(title: TextWithAccessibility(text: "Enviado desde"),
                                                                     value: TextWithAccessibility(text: "Paco P.B"),
                                                                     info: TextWithAccessibility(text: "600 000 000"))),
                BizumDetailItemsViewModel.transferType(ItemDetailViewModel(title: TextWithAccessibility(text: "Tipo de envio"),
                                                                           value: TextWithAccessibility(text: "Bizum sin comision"),
                                                                           info: TextWithAccessibility(text: " 01 de abril"))),
                BizumDetailItemsViewModel.recipients([ReceiverDetailViewModel(value: TextWithAccessibility(text: "676 676 787"))],
                                                     title: TextWithAccessibility(text: "Destino")),
                BizumDetailItemsViewModel.multimedia([MultimediaType.note("Note")])]
    }
}
