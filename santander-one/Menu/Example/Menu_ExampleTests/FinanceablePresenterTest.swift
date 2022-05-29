import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
import UI

@testable import Menu_Example
@testable import Menu
@testable import CoreFoundationLib

final class FinanceablePresenterTest: XCTestCase {
    
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var sut: FinanceablePresenterProtocol!
    private var mockDataInjector = MockDataInjector()
    private var manager = MockFinanceableManager()
    private let view = MockView()
    private var mockSuperUseCase: MockGetAllCardSettlementsSuperUseCase!
    
    // MARK: LifeCycle
    override func setUp() {
        super.setUp()
        sut = FinanceablePresenter(dependenciesResolver: dependencies)
        sut.view = view
        setUpDependencies()
        mockSuperUseCase = MockGetAllCardSettlementsSuperUseCase(dependenciesResolver: dependencies)
        dependencies.register(for: GetAllCardSettlementsSuperUseCase.self) { resolver in
            self.mockSuperUseCase
        }
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func setUpDependencies() {
        dependencies.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
                   MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        dependencies.register(for: PullOffersInterpreter.self) { _ in
            return PullOffersInterpreterMock()
        }
        dependencies.register(for: FinanceableManagerProtocol.self) { _ in
            self.manager
        }
        dependencies.register(for: TrackerManager.self) { _ in
            TrackerManagerMock()
        }
        dependencies.register(for: UseCaseHandler.self) { resolver in
            UseCaseHandler(maxConcurrentOperationCount: 1, qualityOfService: .default)
        }
        dependencies.register(for: BaseURLProvider.self) { resolver in
            BaseURLProvider(baseURL: "")
        }
        dependencies.register(for: TimeManager.self) { resolver in
            TimeManagerMock()
        }
    }
    
    func test_viewDidLoad_whenManagerResponseWithOutCards_shouldNotRenderReceiptsCarousel() {
        sut.viewDidAppear()
        manager.completeFetch(with: self.makeFinanceableInfoViewModel(includeCards: false), info: self.makeFinanceableInfo())
        XCTAssertTrue(self.view.setCardCarouselCount == 0)
        XCTAssertTrue(self.view.setOffersCount == 0)
    }
    
    func test_viewDidLoad_whenManagerResponseWithOffers_shouldRenderOffersSection() {
        sut.viewDidAppear()
        manager.completeFetch(with: self.makeFinanceableInfoViewModel(includeCards: false), info: self.makeFinanceableInfo())
        manager.completeFetchOffers(with: self.makeFinanceableInfoViewModelFilled(includeCards: false))
        XCTAssertTrue(self.view.setOffersCount == 1)
    }
    
    func test_viewDidLoad_whenManagerResponseWithoutOffers_shouldNotRenderOffersSection() {
        sut.viewDidAppear()
        manager.completeFetch(with: self.makeFinanceableInfoViewModel(includeCards: false), info: self.makeFinanceableInfo())
        manager.completeFetchOffers(with: self.makeFinanceableInfoViewModel(includeCards: false))
        XCTAssertTrue(self.view.setOffersCount == 0)
    }
    
    func test_viewDidLoad_whenManagerResponseWithCards_shouldRenderReceiptsCarousel() {
        sut.viewDidAppear()
        manager.completeFetch(with: makeFinanceableInfoViewModel(includeCards: true), info: self.makeFinanceableInfo())
        XCTAssertTrue(self.view.setCardCarouselCount == 1)
    }
    
    func test_viewDidLoad_whenManagerResponseWithCards_shouldAskSuperUseCaseForData() {
        sut.viewDidAppear()
        manager.completeFetch(with: makeFinanceableInfoViewModel(includeCards: true), info: self.makeFinanceableInfo())
        XCTAssertTrue(self.mockSuperUseCase.executeCalls == 1)
    }
    
    func test_viewDidLoad_whenSuperUseCaseResponseWithError_shouldSendEmptyViewModels() {
        sut.viewDidAppear()
        manager.completeFetch(with: makeFinanceableInfoViewModel(includeCards: true), info: self.makeFinanceableInfo())
        mockSuperUseCase.completeWith(error: "an error")
        XCTAssertTrue(mockSuperUseCase.executeCalls == 1)
        XCTAssertTrue(view.viewModels.isEmpty)
    }
    
    func test_viewDidLoad_whenSuccessSuperUseCaseResponseWithEmptyData_shouldSendEmptyViewModels() {
        sut.viewDidAppear()
        manager.completeFetch(with: makeFinanceableInfoViewModel(includeCards: true), info: self.makeFinanceableInfo())
        mockSuperUseCase.completeWith([])
        XCTAssertTrue(mockSuperUseCase.executeCalls == 1)
        XCTAssertTrue(view.viewModels.isEmpty)
    }
    
    func test_viewDidLoad_whenSuccessSuperUseCaseResponseWithData_shouldNotCreateViewModelsWithZeroAmountValue() {
        sut.viewDidAppear()
        manager.completeFetch(with: makeFinanceableInfoViewModel(includeCards: true), info: self.makeFinanceableInfo())
        mockSuperUseCase.completeWith([makeSettlementOutputWithAmount(nil)])
        XCTAssertTrue(mockSuperUseCase.executeCalls == 1)
        XCTAssertTrue(view.viewModels.isEmpty)
    }
    
    func test_viewDidLoad_whenSuccessSuperUseCaseResponseWithData_shouldCreateViewModels() {
        sut.viewDidAppear()
        manager.completeFetch(with: makeFinanceableInfoViewModel(includeCards: true), info: self.makeFinanceableInfo())
        mockSuperUseCase.completeWith([makeSettlementOutputWithAmount(67.7)])
        XCTAssertTrue(mockSuperUseCase.executeCalls == 1)
        XCTAssertTrue(view.viewModels.count == 1)
    }
}

private extension CardEntity {
    convenience init() {
        self.init(CardDTO())
    }
}

private extension CardSettlementDetailDTO {
    init() {
        self.init(errorCode: 1)
    }
}

private extension FinanceablePresenterTest {
    
    func makeSettlementOutputWithAmount(_ amount: Double?) -> GetCardsSettlementsOutput {
        let cardDto = CardDTO()
        let cardEntity = CardEntity(cardDto)
        var settlementDTO = CardSettlementDetailDTO()
        if let amount = amount {
            settlementDTO.totalAmount = amount
        }
        
        let cardSettlementDetailEntity = CardSettlementDetailEntity(settlementDTO)
        return GetCardsSettlementsOutput(cardEntity: cardEntity,
                                             cardSettlementDetailEntity: cardSettlementDetailEntity)
    }
    
    func makeFinanceableInfoViewModel(includeCards: Bool) -> FinanceableInfoViewModel {
        var cardDto = CardDTO()
        cardDto.ownershipType = "01"
        let cards = includeCards ? [CardEntity(cardDto), CardEntity(cardDto)] : []
        return FinanceableInfoViewModel(accountsCarousel: nil,
                                            cardsCarousel: FinanceableInfoViewModel.CardsCarousel(
                                                cards: cards,
                                                isSanflixEnabled: true,
                                                offer: nil),
                                            preconceivedBanner: nil,
                                            robinsonOffer: nil,
                                            bigOffer: nil,
                                            tricks: nil,
                                            secondBigOffer: nil,
                                            adobeTarget: nil,
                                            fractionalPayment: nil,
                                            commercialOffers: nil)
    }
    
    func makeFinanceableInfoViewModelFilled(includeCards: Bool) -> FinanceableInfoViewModel {
        var cardDto = CardDTO()
        cardDto.ownershipType = "01"
        let cards = includeCards ? [CardEntity(cardDto), CardEntity(cardDto)] : []
        let needMoney = FinanceableInfoViewModel.NeedMoney(amount: nil, offer: nil)
        return FinanceableInfoViewModel(accountsCarousel: nil,
                                            cardsCarousel: FinanceableInfoViewModel.CardsCarousel(
                                                cards: cards,
                                                isSanflixEnabled: true,
                                                offer: nil),
                                            preconceivedBanner: needMoney,
                                            robinsonOffer: nil,
                                            bigOffer: nil,
                                            tricks: nil,
                                            secondBigOffer: nil,
                                            adobeTarget: nil,
                                            fractionalPayment: nil,
                                            commercialOffers: nil)
    }
    
    func makeFinanceableInfo() -> FinanceableInfo {
        return FinanceableInfo()
    }
}

fileprivate final class MockFinanceableManager: FinanceableManagerProtocol {
    
    private var loadRequests = [(FinanceableInfoViewModel,FinanceableInfo) -> Void]()
    private var loadOfferRequests = [(FinanceableInfoViewModel) -> Void]()
    
    func fetch(completion: @escaping (FinanceableInfoViewModel, FinanceableInfo) -> Void) {
        loadRequests.append(completion)
    }
    
    func fetchOffers(firstFectchInfo: FinanceableInfo, completion: @escaping (FinanceableInfoViewModel) -> Void) {
        loadOfferRequests.append(completion)
    }
    
    func completeFetch(with viewModel: FinanceableInfoViewModel, info: FinanceableInfo, at index: Int = 0) {
        loadRequests[index](viewModel,info)
    }
    
    func completeFetchOffers(with viewModel: FinanceableInfoViewModel, at index: Int = 0) {
        loadOfferRequests[index](viewModel)
    }
}

fileprivate final class MockView: UIViewController {
    var setCardCarouselCount = 0
    var setOffersCount = 0
    var viewModels: [BankableCardReceiptViewModel] = []
    var associatedLoadingView: UIViewController { self }
}

extension MockView: LoadingViewPresentationCapable {
    
    public func showLoading(
        title: LocalizedStylableText = localized("generic_popup_loadingContent"),
        subTitle: LocalizedStylableText = localized("loading_label_moment"),
        completion: (() -> Void)? = nil ) {
            completion?()
    }
    
    func dismissLoading(completion: (() -> Void)?) {
        completion?()
    }
}

extension MockView: FinanceableViewProtocol {
    func setFinanceableOfferSectionView(_ viewModel: FinanceableInfoViewModel, baseUrl: String?) {
        setOffersCount += 1
    }
    
    
    func setLoadingView(completion: (() -> Void)?) {
        completion?()
    }
    
    func hideLoadingView(completion: (() -> Void)?) {
        completion?()
    }
    
    func setCardCarouselViewState(_ viewState: CardsCarouselViewState) {
        
    }
    
    func showFinancingTricks(_ viewModels: [TrickViewModel]) {
        
    }
    
    func hideFinancingTricks() {
        
    }
    
    func showFinancingTricksCurtainView(viewModels: [TrickViewModel], index: Int) {
        
    }
    
    func setAccountCarouselViewState(_ viewState: AccountCarouselViewState) {
        
    }
    
    func setFractionalPaymentsView(_ viewModel: FinanceableInfoViewModel) {
        
    }
    
    func setCardCarouselView() {
        setCardCarouselCount += 1
    }
    
    func setRobinsonOfferView(_ viewModel: FinanceableInfoViewModel) {
        
    }
    
    func setPreconceivedBannerView(_ viewModel: FinanceableInfoViewModel) {
        
    }
    
    func setAdobeTargetOfferView(_ viewModel: FinanceableInfoViewModel) {
        
    }
    
    func setCommercialOffers(_ viewModel: CommercialOffersViewModel) {
        
    }
    
    func setBankableCardReceiptsView(_ viewModels: [BankableCardReceiptViewModel]) {
        self.viewModels.append(contentsOf: viewModels)
    }
    
    func setTitleView() {
        
    }
}

fileprivate  final class MockGetAllCardSettlementsSuperUseCase: GetAllCardSettlementsSuperUseCase {
    
    var executeCalls = 0
    
    func completeWith(_ response: [GetCardsSettlementsOutput]) {
        delegate?.didFinishGetCardsSettlementsSuccessfully(with: response)
    }
    
    func completeWith(error: String?) {
        delegate?.didFinishWithError(error: error)
    }
    
    override func executeWith(cards: [CardEntity]) {
        executeCalls += 1
    }
}
