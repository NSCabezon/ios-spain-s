import CoreFoundationLib
import Operative

protocol UpdateSubscriptionSummaryPresenterProtocol: OperativeSummaryPresenterProtocol, MenuTextWrapperProtocol {
    func viewDidLoad()
}

final class UpdateSubscriptionSummaryPresenter {
    weak var view: OperativeSummaryViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var shouldShowProgressBar: Bool = false
    var isBackable: Bool = false
    var container: OperativeContainerProtocol?
    var operativeData: UpdateSubscriptionOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension UpdateSubscriptionSummaryPresenter {
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }

    func configureView() {
        var summaryViewModel: OperativeSummaryStandardViewModel? {
            let builder = UpdateSubscriptionSummaryBuilder(
                operativeData: operativeData,
                dependenciesResolver: dependenciesResolver)
            builder.addReceipt()
            builder.addGoToMyCards {
                self.goToMyCards()
            }
            builder.addGoToGlobalPosition {
                self.goToGlobalPosition()
            }
            builder.addGoToOpinator {
                self.goToOpinator()
            }
            return builder.build()
        }
        guard let viewModel = summaryViewModel else { return }
        self.view?.setupStandardHeader(with: viewModel.header)
        self.view?.setupStandardBody(
            withItems: viewModel.bodyItems,
            actions: viewModel.bodyActionItems,
            collapsableSections: .noCollapsable)
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
    }

    // MARK: Footer Actions

    func goToMyCards() {
        self.container?.save(UpdateSubscriptionOperative.FinishingOption.cardsHome)
        self.container?.stepFinished(presenter: self)
    }

    func goToGlobalPosition() {
        self.container?.save(UpdateSubscriptionOperative.FinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }

    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
        self.trackEvent(.opinator)
    }
}

extension UpdateSubscriptionSummaryPresenter: UpdateSubscriptionSummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.configureView()
    }
}

extension UpdateSubscriptionSummaryPresenter: AutomaticScreenActionTrackable {
    var trackerPage: UpdateSubscriptionSummaryPage {
        UpdateSubscriptionSummaryPage()
    }
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
