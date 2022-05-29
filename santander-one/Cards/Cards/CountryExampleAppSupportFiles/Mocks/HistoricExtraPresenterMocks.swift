import CoreFoundationLib
import SANLegacyLibrary
import Operative
import CoreDomain
import UI
@testable import Cards

final class GetHistoricExtractUseCaseMock: HistoricExtractUseCase {
    private let dependencies = DependenciesDefault()
    var output: GetHistoricExtractUseCaseOkOutput?
    
    override func executeUseCase(requestValues: GetHistoricExtractUseCaseInput) throws -> UseCaseResponse<GetHistoricExtractUseCaseOkOutput, StringErrorOutput> {
        if let output = output {
            return UseCaseResponse.ok(output)
        }
        return UseCaseResponse.error(StringErrorOutput("Error in Mocked UseCase"))
    }

    func setupOutput() {
        let cardSettlementDetailDto = CardSettlementDetailDTO()
        let cardSettlementDetailEntity = CardSettlementDetailEntity(cardSettlementDetailDto)
        let paymentMethodType = PaymentMethodType.monthlyPayment
        let cardPaymentEntity = CardPaymentMethodTypeEntity(paymentMethodType)
        let cardDetailDTO = CardDetailDTO()
        let cardDetailEntity = CardDetailEntity(cardDetailDTO)
        self.output = GetHistoricExtractUseCaseOkOutput(cardSettlementDetailEntity: cardSettlementDetailEntity, scaDate: Date(), currentPaymentMethod: cardPaymentEntity, currentPaymentMethodMode: "", settlementMovementsList: [], cardDetailEntity: cardDetailEntity, isEnableCardsHomeLocationMap: true)
    }
    
    func setStartDateOrEndDateNil() {
        var cardSettlementDetailDto = CardSettlementDetailDTO()
        cardSettlementDetailDto.startDate = nil
        cardSettlementDetailDto.endDate = nil
        let cardSettlementDetailEntity = CardSettlementDetailEntity(cardSettlementDetailDto)
        let paymentMethodType = PaymentMethodType.monthlyPayment
        let cardPaymentEntity = CardPaymentMethodTypeEntity(paymentMethodType)
        let cardDetailDTO = CardDetailDTO()
        let cardDetailEntity = CardDetailEntity(cardDetailDTO)
        self.output = GetHistoricExtractUseCaseOkOutput(cardSettlementDetailEntity: cardSettlementDetailEntity, scaDate: Date(), currentPaymentMethod: cardPaymentEntity, currentPaymentMethodMode: "", settlementMovementsList: [], cardDetailEntity: cardDetailEntity, isEnableCardsHomeLocationMap: true)
    }
    
    func setStartDateOrEndDateNilAndDisabledMap() {
        var cardSettlementDetailDto = CardSettlementDetailDTO()
        cardSettlementDetailDto.startDate = nil
        cardSettlementDetailDto.endDate = nil
        let cardSettlementDetailEntity = CardSettlementDetailEntity(cardSettlementDetailDto)
        let paymentMethodType = PaymentMethodType.monthlyPayment
        let cardPaymentEntity = CardPaymentMethodTypeEntity(paymentMethodType)
        let cardDetailDTO = CardDetailDTO()
        let cardDetailEntity = CardDetailEntity(cardDetailDTO)
        self.output = GetHistoricExtractUseCaseOkOutput(cardSettlementDetailEntity: cardSettlementDetailEntity, scaDate: Date(), currentPaymentMethod: cardPaymentEntity, currentPaymentMethodMode: "", settlementMovementsList: [], cardDetailEntity: cardDetailEntity, isEnableCardsHomeLocationMap: false)
    }
    
    func setStartDateAndEndDate() {
        var cardSettlementDetailDto = CardSettlementDetailDTO()
        cardSettlementDetailDto.startDate = Date()
        cardSettlementDetailDto.endDate = Date().addMonth(months: 2)
        let cardSettlementDetailEntity = CardSettlementDetailEntity(cardSettlementDetailDto)
        let paymentMethodType = PaymentMethodType.monthlyPayment
        let cardPaymentEntity = CardPaymentMethodTypeEntity(paymentMethodType)
        let cardDetailDTO = CardDetailDTO()
        let cardDetailEntity = CardDetailEntity(cardDetailDTO)
        self.output = GetHistoricExtractUseCaseOkOutput(cardSettlementDetailEntity: cardSettlementDetailEntity, scaDate: Date(), currentPaymentMethod: cardPaymentEntity, currentPaymentMethodMode: "", settlementMovementsList: [], cardDetailEntity: cardDetailEntity, isEnableCardsHomeLocationMap: true)
    }
}

final class FinishingCoordinatorMock: HistoricExtractOperativeFinishingCoordinatorProtocol {
    var goToHistoricExtractCalled = false
    var selectedCard: CardEntity?
    var cardConfiguration: CardMapTypeConfiguration?
    
    func goToHistoricExtract() {
        goToHistoricExtractCalled = true
    }
    
    func goToMapView(_ selectedCard: CardEntity, type: CardMapTypeConfiguration) {
        self.selectedCard = selectedCard
        self.cardConfiguration = type
    }
}

final class OperativeMock: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var container: OperativeContainerProtocol?
    var steps: [OperativeStep] = []
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
    }
}

final class CoordinatorProtocolMock: OperativeContainerCoordinatorProtocol {
    func executeOffer(_ offer: OfferRepresentable) { }
    
    var navigationController: UINavigationController?
    
    var sourceView: UIViewController?
    
    func presentModal(_ step: OperativeView) {}
    
    func push(_ step: OperativeView) {}
    
    func handleOpinator(_ opinator: OpinatorInfoRepresentable) {}
    
    func handleGiveUpOpinator(_ opinator: OpinatorInfoRepresentable, completion: @escaping () -> Void) {}
    
    func share(_ shareable: Shareable, type: ShareType?) {}
    
    func handleWebView(with data: Data, title: String) {}
        
    var operativeViews: [OperativeView] = []
    
    func append(_ step: OperativeView) {}
}

final class ContainerProtocolMock: OperativeContainerProtocol {

    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.operative = OperativeMock(dependencies: dependencies)
        self.coordinator = CoordinatorProtocolMock()
    }
    
    var handler: OperativeLauncherHandler?
    
    var coordinator: OperativeContainerCoordinatorProtocol
    
    var operative: Operative
    
    func get<T>() -> T {
        guard let container = operative.container else {
            return operative.dependencies.resolve()
        }
        return container.get()
    }
    
    func getOptional<T>() -> T? {
        return operative.container?.getOptional()
    }
    
    func save<T>(_ parameter: T) { }
    
    func close() { }
    
    func goToFirstOperativeStep() { }
    
    func stepFinished(presenter: OperativeStepPresenterProtocol) { }
    
    func didSwipeBack() { }
    
    func progressBarAlpha(_ value: CGFloat) { }
    
    func back() { }
    
    func back<Presenter>(to type: Presenter.Type) where Presenter : OperativeStepPresenterProtocol { }
    
    func back<Presenter>(to type: Presenter.Type, creatingAt index: Int, step: OperativeStep) where Presenter : OperativeStepPresenterProtocol { }
    
    func go<Presenter: OperativeStepPresenterProtocol>(to type: Presenter.Type) { }
    
    func bringProgressBarToTop() { }
    
    func rebuildSteps() { }
    
    func trackFaqEvent(_ question: String, url: URL?) { }
    
    func showGenericError() { }
    
    func restoreProgressBar() { }
    
    func showGiveUpDialog() { }
    
    func dismissOperative() { }
    
    func getStepOfSteps<Presenter>(presenter: Presenter) -> [Int] where Presenter : OperativeStepPresenterProtocol {
        return []
        
    }
    
    func getSubtitleInfo<Presenter>(presenter: Presenter) -> String where Presenter : OperativeStepPresenterProtocol {
        return ""
    }
    
    func currentStep() -> OperativeStepPresenterProtocol? {
        return nil
    }
    
    func updateLastViewController() {}
    
    func clearParametersOfType<T>(type: T.Type) {}
    
}

final class HistoricExtractViewMock: HistoricExtractViewProtocol {
    var associatedViewController: UIViewController
    var operativePresenter: OperativeStepPresenterProtocol
    var title: String?
    var associatedOldDialogView: UIViewController
    var progressBarBackgroundColor: UIColor
    
    var headerViewModel: NextSettlementViewModel?
    var groupedViewModel: [GroupedMovementsViewModel]?
    var updateHeaderViewModel: NextSettlementViewModel?
    
    init() {
        self.operativePresenter = StepPresenterProtocolMock()
        self.associatedViewController = UIViewController()
        self.progressBarBackgroundColor = .skyGray
        self.associatedOldDialogView = UIViewController()
    }
    
    func setHeaderViewModel(_ headerViewModel: NextSettlementViewModel) {
        self.headerViewModel = headerViewModel
    }
    
    func setGroupedViewModels(_ groupedViewModels: [GroupedMovementsViewModel]) {
        self.groupedViewModel = groupedViewModels
    }
    
    func updateHeaderView(_ viewModel: NextSettlementViewModel) {
        self.updateHeaderViewModel = viewModel
    }
}

final class StepPresenterProtocolMock: OperativeStepPresenterProtocol {
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
}

extension CardSettlementDetailDTO {
    init() {
        self = CardSettlementDetailDTO(errorCode: 200)
        startDate = Date()
        endDate = Date().addMonth(months: 1)
        ascriptionDate = Date()
        paymentMethodSettlement = 0
        paymentMethodCard = 1
        actualDeposit = Double(140.0)
        totalAmount = Double(56.3)
        commission = Double(2.5)
        interest = Double(0.5)
        capital = nil
        authorizedATM = nil
        extractNumber = nil
        errorCode = nil
    }
}
