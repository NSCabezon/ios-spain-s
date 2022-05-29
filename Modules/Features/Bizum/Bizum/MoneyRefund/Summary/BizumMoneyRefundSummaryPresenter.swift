//
//  BizumRefundMoneySummaryPresenter.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 11/12/20.
//

import Foundation
import Operative
import CoreFoundationLib

protocol BizumRefundMoneySummaryPresenterProtocol: OperativeSummaryPresenterProtocol {}

extension BizumRefundMoneySummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

class BizumRefundMoneySummaryPresenter {
    weak var view: OperativeSummaryViewProtocol?
    var bizumView: BizumSummaryViewProtocol? {
        view as? BizumSummaryViewProtocol
    }
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    private lazy var operativeData: BizumRefundMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumRefundMoneySummaryPresenter: BizumRefundMoneySummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        let builder = BizumRefundMoneySummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addDestinationBizumContacts()
        builder.addDate()
        builder.addComment()
        builder.addShare(withAction: share)
        builder.addGoToBizumHome(withAction: goToBizumHome)
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addGoToOpinator(withAction: goToOpinator)
        }
        let viewModel = builder.build()
        self.view?.setupStandardHeader(with: viewModel.header)
        self.bizumView?.setupBizumBody(viewModel.bodyItems, actions: viewModel.bodyActionItems, showLastSeparator: false, shareViewModel: nil, whatsAppAction: nil)
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
    }
}

private extension BizumRefundMoneySummaryPresenter {
    
    func share() {
        self.container?.coordinator.share(self, type: .text)
    }
    
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

extension BizumRefundMoneySummaryPresenter: Shareable {
    func getShareableInfo() -> String {
        trackEvent(.share, parameters: [:])
        let builder = BizumRefundMoneySummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        return builder.build().bodyItems.map { viewModel in
            var subtitle = ""
            if case let .standard(data) = viewModel.metadata {
                subtitle = data.subTitle.string
            }
            return viewModel.title + " " + subtitle
        }.joined(separator: "\n")
    }
}

extension BizumRefundMoneySummaryPresenter: AutomaticScreenActionTrackable {
    var trackerPage: BizumRefundMoneySummaryPage {
        return BizumRefundMoneySummaryPage()
    }
    
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }

    func getTrackParameters() -> [String: String]? {
        return nil
    }
}
