import Operative
import CoreFoundationLib

protocol DeleteFavouriteSummaryPresenterProtocol: OperativeSummaryPresenterProtocol {
    func close()
}

final class DeleteFavouriteSummaryPresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeSummaryViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = true
    var shouldShowProgressBar: Bool = false
    var container: OperativeContainerProtocol?
    lazy var operativeData: DeleteFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension DeleteFavouriteSummaryPresenter {
    func goToNewSend() {
        self.container?.save(DeleteFavouriteOperative.FinishingOption.home)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(DeleteFavouriteOperative.FinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
}

extension DeleteFavouriteSummaryPresenter: DeleteFavouriteSummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        let builder = DeleteFavouriteSummaryBuilder(operativeData: self.operativeData)
        builder.addAlias()
        builder.addBeneficiary()
        builder.addCountry()
        builder.addNewSend(withAction: self.goToNewSend)
        builder.addGoPG(withAction: self.goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addHelpImprove(withAction: self.goToOpinator)
        }
        let viewModel = builder.build()
        self.view?.setupStandardHeader(with: viewModel.header)
        self.view?.setupStandardBody(
            withItems: viewModel.bodyItems,
            actions: viewModel.bodyActionItems,
            collapsableSections: .noCollapsable
        )
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
    }
    
    func close() {
        self.container?.save(DeleteFavouriteOperative.FinishingOption.operativeFinished)
        self.container?.close()
    }
}

extension DeleteFavouriteSummaryPresenter: AutomaticScreenTrackable {
    var trackerPage: StrategyPageTrackable {
        if (self.operativeData.favouriteType?.isSepa) != nil {
            return StrategyPageTrackable(strategy: DeleteFavouriteSepaSummaryPage())
        } else {
            return StrategyPageTrackable(strategy: DeleteFavouriteNoSepaSummaryPage())
        }
    }
    
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
