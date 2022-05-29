import CoreFoundationLib
import Foundation
import Operative

protocol SummaryAmortizationStepPresenterProtocol: OperativeSummaryPresenterProtocol {}

final class SummaryAmortizationStepPresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeSummaryViewProtocol?
    var summaryView: SummaryAmortizationStepViewProtocol? {
        return view as? SummaryAmortizationStepViewProtocol
    }

    var number: Int = 0
    var isBackButtonEnabled = false
    var isCancelButtonEnabled = false
    var shouldShowProgressBar = false
    var container: OperativeContainerProtocol?
    var timeManager: TimeManager
    lazy var operativeData: LoanPartialAmortizationOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.timeManager = self.dependenciesResolver.resolve()
        trackScreen()
    }
}

private extension SummaryAmortizationStepPresenter {
    func getViewModel() -> SummaryAmortizationViewModel {
        return SummaryAmortizationViewModel(operativeData: operativeData, timeManager: timeManager)
    }

    func buildView() {
        let builder = SummaryAmortizationStepBuilder(viewModel: getViewModel(), dependenciesResolver: dependenciesResolver)
        // Body views
        builder.addLoanAmount()
        builder.addLoanAlias()
        builder.addLoanContractNumber()
        builder.addHolder()
        builder.addPending()
        builder.addExpiringDate()
        builder.addInitialLimit()
        builder.addAmortizationType()
        builder.addValueDate()
        builder.addAmortizationAmount()
        if operativeData.partialAmortization?.isNewMortgageLawLoan ?? false {
            builder.addFinantialLoss()
            builder.addCompensation()
            builder.addNewInsuranceFee()
        }
        // Body Actions
        builder.addShare(withAction: share)
        // Footer
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        builder.addHelpUsToImprove(withAction: goToHelpToImprove)
        let viewModel = builder.build()
        view?.setupStandardHeader(with: viewModel.header)
        view?.setupStandardBody(withItems: viewModel.bodyItems,
                                actions: viewModel.bodyActionItems,
                                collapsableSections: .defaultCollapsable(visibleSections: 4))
        view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"),
                                           items: viewModel.footerItems)
        view?.build()
    }

    func share() {
        container?.coordinator.share(self, type: .text)
    }

    func goToGlobalPosition() {
        container?.save(LoanPartialAmortizationFinishingOption.globalPosition)
        container?.stepFinished(presenter: self)
    }

    func goToHelpToImprove() {
        guard let opinatorCapable = container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
}

extension SummaryAmortizationStepPresenter: Shareable {
    func getShareableInfo() -> String {
        trackEvent(.share, parameters: [:])
        let builder = SummaryAmortizationStepBuilder(viewModel: getViewModel(), dependenciesResolver: dependenciesResolver)
        builder.addLoanAmount()
        builder.addLoanAlias()
        builder.addLoanContractNumber()
        builder.addHolder()
        builder.addPending()
        builder.addExpiringDate()
        builder.addInitialLimit()
        builder.addAmortizationType()
        builder.addValueDate()
        builder.addAmortizationAmount()
        if operativeData.partialAmortization?.isNewMortgageLawLoan ?? false {
            builder.addFinantialLoss()
            builder.addCompensation()
            builder.addNewInsuranceFee()
        }
        let dataString = builder.build().bodyItems.map { viewModel in
            viewModel.title + ": " + viewModel.subTitle.string
        }.joined(separator: "\n")
        let title: String = localized("summary_title_anticipatedAmortization")
        return "\(title)\n\n\(dataString)"
    }
}

extension SummaryAmortizationStepPresenter: SummaryAmortizationStepPresenterProtocol {
    func viewDidLoad() {
        buildView()
    }
}

extension SummaryAmortizationStepPresenter: AutomaticScreenActionTrackable {
    var trackerPage: LoanPartialAmortizationSummaryPage {
        return LoanPartialAmortizationSummaryPage()
    }

    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
