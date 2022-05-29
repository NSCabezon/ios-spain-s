import CoreFoundationLib
import XCTest
import QuickSetup
@testable import Bizum

class BizumSendAgainCoordinatorTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private var sut: BizumSendAgainCoordinator?
    private var presenter: BizumSendAgainPresenter?
    private let type: BizumEmitterType = .send
    private var coordinatorMock: BizumSendAgainCoordinatorMock?
    private let amount = "23,00"
    private let concept = "concept"
    private let phone = "34625312027"

    override func setUpWithError() throws {
        self.dependencies.register(for: BizumSendAgainCoordinatorProtocol.self, with: { _ in
            let coordinatorMock = BizumSendAgainCoordinatorMock()
            self.coordinatorMock = coordinatorMock
            return coordinatorMock
        })
        self.dependencies.register(for: TrackerManager.self, with: { _ in
            return TrackerManagerMock()
        })
        self.registerConfigurationToSend()
        self.presenter = BizumSendAgainPresenter(dependenciesResolver: dependencies)
    }

    func testReuseSendShouldSendAmountAndConcept() {
        self.presenter?.viewDidLoad()
        self.presenter?.didSelectReuseSendAgain()
        let amount = self.coordinatorMock?.viewModel?.bizumSendMoney.amount.getFormattedValue() ?? ""
        let concept = self.coordinatorMock?.viewModel?.bizumSendMoney.concept
        XCTAssert(amount == self.amount && concept == self.concept)
    }

    func testReuseSendShouldSendTrue() {
        self.presenter?.viewDidLoad()
        self.presenter?.didSelectReuseSendAgain()
        assert(self.coordinatorMock?.isSelectedSendAgain ?? false)
    }

    func testReuseSendShouldContactExist() {
        self.presenter?.viewDidLoad()
        self.presenter?.didSelectReuseSendAgain()
        let contact = self.coordinatorMock?.viewModel?.contact
        XCTAssert(contact?.phone == phone)
    }
}

private extension BizumSendAgainCoordinatorTest {
    func registerConfigurationToSend() {
        let contact = BizumContactEntity(identifier: phone, name: "lorem inpsum", phone: phone, alias: "lorem inpsum")
        let decimalAmount = Decimal(string: self.amount) ?? 0.0
        let sendMoney = BizumSendMoney(amount: AmountEntity(value: decimalAmount),
                                       totalAmount: AmountEntity(value: decimalAmount),
                                       concept: self.concept)
        self.dependencies.register(for: BizumSendAgainConfiguration.self) { _ in
            return BizumSendAgainConfiguration(self.type, contact: contact, sendMoney: sendMoney, items: self.generateItemFromSend())
        }
    }

    func generateItemFromSend() -> [BizumDetailItemsViewModel] {
        return [BizumDetailItemsViewModel.amount(ItemDetailAmountViewModel(title: TextWithAccessibility(text: "lorem inpsum"),
                                                                           amount: AmountEntity(value: Decimal(0.0)),
                                                                           info: TextWithAccessibility(text: "lorem inpsum"))),
                BizumDetailItemsViewModel.origin(ItemDetailViewModel(title: TextWithAccessibility(text: "lorem inpsum"),
                                                                     value: TextWithAccessibility(text: "lorem inpsum"),
                                                                     info: TextWithAccessibility(text: "lorem inpsum"))),
                BizumDetailItemsViewModel.transferType(ItemDetailViewModel(title: TextWithAccessibility(text: "lorem inpsum"),
                                                                           value: TextWithAccessibility(text: "lorem inpsum"),
                                                                           info: TextWithAccessibility(text: "lorem inpsum"))),
                BizumDetailItemsViewModel.recipients([ReceiverDetailViewModel(value: TextWithAccessibility(text: "lorem inpsum"))],
                                                     title: TextWithAccessibility(text: "lorem inpsum")),
                BizumDetailItemsViewModel.multimedia([MultimediaType.note("lorem inpsum")])]
    }
}

private class BizumSendAgainCoordinatorMock: BizumSendAgainCoordinatorProtocol {
    
    var viewModel: BizumSendAgainOperativeViewModel?
    var isSelectedSendAgain: Bool?

    func didSelectSendAgain(_ viewModel: BizumSendAgainOperativeViewModel) {
        self.viewModel = viewModel
        self.isSelectedSendAgain = true
    }

    func didSelectRequestAgain(_ viewModel: BizumSendAgainOperativeViewModel) {
        self.viewModel = viewModel
        self.isSelectedSendAgain = false
    }
    
    func sendAgainViewDisappear() {
        
    }
}
