import Operative
import CoreFoundationLib
import UI

protocol EasyPaySummaryPresenterProtocol: OperativeSummaryPresenterProtocol {}

extension EasyPaySummaryPresenterProtocol {
    var shouldShowProgressBar: Bool { false }
    var isBackable: Bool { false }
}

final class EasyPaySummaryPresenter {
    weak var view: OperativeSummaryViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled = false
    var isCancelButtonEnabled = false
    var number: Int = 0
    lazy var operativeData: EasyPayOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    private var shareCapableOperative: ShareOperativeCapable? {
        self.container?.operative as? ShareOperativeCapable
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var useCase: GetFinancingUseCase {
        return dependenciesResolver.resolve(for: GetFinancingUseCase.self)
    }
}

extension EasyPaySummaryPresenter: EasyPaySummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        Scenario(useCase: useCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess(buildView)
    }
    
    private func buildView(result: GetFinancingUseCaseOkOutput) {
        let builder = EasyPaySummaryBuilder(operativeData: operativeData,
                                            dependenciesResolver: dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addNumberOfFees()
        builder.addFeeValue()
        builder.addStartDate()
        builder.addEndDate()
        builder.addShareAction(withAction: share)
        builder.addMoreBuysAction(withAction: goToMoreFinantiableBuys)
        if result.financingEnabled {
            builder.addGoTofinancing(withAction: goToFinancing)
        }
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        builder.addHelpUsToImprove(withAction: goToOpinator)
        let viewModel = builder.build()
        view?.setupStandardHeader(with: viewModel.header)
        view?.setupStandardBody(withItems: viewModel.bodyItems,
                                     actions: viewModel.bodyActionItems,
                                     collapsableSections: .noCollapsable)
        view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"),
                                           items: viewModel.footerItems)
        view?.build()
    }
}

private extension EasyPaySummaryPresenter {
    
    func share() {
        shareCapableOperative?.getShareView(completion: { [weak self] result in
            switch result {
            case .success((let shareView, let view)):
                guard
                    let self = self,
                    let shareView = shareView,
                    let containerView = view
                else { return }
                self.container?.coordinator.share(self, type: .image(shareView, containerView))
            case .failure:
                return
            }
        })
    }
    
    func goToGlobalPosition() {
        self.container?.save(EasyPayFinishingOption.globalPosition)
        container?.stepFinished(presenter: self)
    }
    
    func goToFinancing() {
        self.container?.save(EasyPayFinishingOption.financing)
        container?.stepFinished(presenter: self)
    }
 
    func goToOpinator() {
        guard
            let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative
        else { return }
        opinatorCapable.showOpinator()
    }
    
    func goToMoreFinantiableBuys() {
        guard let view = view as? EasyPaySummaryViewProtocol else { return }
        view.showComingSoonToast()
    }
}

extension EasyPaySummaryPresenter: Shareable {
    
    func getShareableInfo() -> String {
        return ""
    }
}

extension EasyPaySummaryPresenter: AutomaticScreenTrackable {

   var trackerPage: EasyPaySummaryPage {
        EasyPaySummaryPage()
    }

    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }

    func getTrackParameters() -> [String: String]? {
        guard
            let amount = operativeData.easyPayContractTransaction?.amount,
            let currency = amount.currency
        else { return nil }
        
        return [TrackerDimension.amount.key: amount.getFormattedTrackValue(),
                TrackerDimension.currency.key: currency]
    }
}
