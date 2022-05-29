import Foundation
import CoreFoundationLib
import Operative

protocol BizumCancelSummaryPresenterProtocol: OperativeSummaryPresenterProtocol {}

extension BizumCancelSummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
    
    var isBackable: Bool {
        false
    }
}

final class BizumCancelSummaryPresenter {
    weak var view: OperativeSummaryViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    lazy var operativeData: BizumCancelOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumCancelSummaryPresenter: BizumCancelSummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        let builder = BizumCancelSummaryBuilder(operativeData: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addSendingDate()
        builder.addDestinationPhone()
        builder.addGoToBizumHome(withAction: goToBizumHome)
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addGoToOpinator(withAction: goToOpinator)
        }
        let viewModel = builder.build()
        self.view?.setupStandardHeader(with: viewModel.header)
        self.view?.setupStandardBody(withItems: viewModel.bodyItems, actions: viewModel.bodyActionItems, collapsableSections: .noCollapsable)
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
    }
}

private extension BizumCancelSummaryPresenter {
    func goToBizumHome() {
        self.container?.save(BizumFinishingOption.home)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(BizumFinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
}

extension BizumCancelSummaryPresenter: AutomaticScreenTrackable {
    var trackerPage: BizumCancelSummaryPage {
        BizumCancelSummaryPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
