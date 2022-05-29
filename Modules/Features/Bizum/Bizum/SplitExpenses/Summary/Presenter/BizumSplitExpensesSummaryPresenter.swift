//
//  BizumSplitExpensesSummaryPresenter.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 15/01/2021.
//

import Foundation
import CoreFoundationLib
import Operative

final class BizumSplitExpensesSummaryPresenter {
    weak var summaryView: BizumSummaryViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    lazy var operativeData: BizumSplitExpensesOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private var shareCapableOperative: ShareOperativeCapable? {
        self.container?.operative as? ShareOperativeCapable
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumSplitExpensesSummaryPresenter: BizumSendMoneySummaryPresenterProtocol {
    var view: OperativeSummaryViewProtocol? {
        get {
            return self.summaryView
        }
        set {
            self.summaryView = newValue as? BizumSummaryViewProtocol
        }
    }
    
    func viewDidLoad() {
        let builder = BizumSplitExpensesSummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addMultimediaContent()
        builder.addDestinationBizumContacts()
        builder.addShare(withAction: share)
        builder.addGoToBizumHome(withAction: goToBizumHome)
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addGoToOpinator(withAction: goToOpinator)
        }
        let viewModel = builder.build()
        self.summaryView?.setupStandardHeader(with: viewModel.header)
        self.summaryView?.setupBizumBody(viewModel.bodyItems, actions: viewModel.bodyActionItems, showLastSeparator: false, shareViewModel: nil, whatsAppAction: nil)
        self.view?.setupStandardFooterWithTitle(localized("summary_label_nowThat"), items: viewModel.footerItems)
        self.view?.build()
    }
}

private extension BizumSplitExpensesSummaryPresenter {
    
    func share() {
        trackShareByImage()
        shareCapableOperative?.getShareView { [weak self] result in
            switch result {
            case .success(let shareView, let view):
                guard
                    let self = self,
                    let shareView = shareView,
                    let containerView = view
                else { return }
                self.container?.coordinator.share(self, type: .image(shareView, containerView))
            case .failure:
                break
            }
        }
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
    
    func trackShareByImage() {
        guard let type = operativeData.simpleMultipleType else {
            return
        }
        let typeParameter: String
        switch type {
        case .simple:
            typeParameter = BizumSimpleMultipleType.simple.rawValue
        case .multiple:
            typeParameter = BizumSimpleMultipleType.multiple.rawValue
        }
        self.trackEvent(.share, parameters: [TrackerDimension.simpleMultipleType: typeParameter])
    }
}

extension BizumSplitExpensesSummaryPresenter: Shareable {
    func getShareableInfo() -> String {
        trackEvent(.share, parameters: [.simpleMultipleType: self.operativeData.simpleMultipleType?.rawValue ?? ""])
        let builder = BizumSplitExpensesSummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        return builder.build().bodyItems.map { viewModel in
            var subtitle = ""
            if case let .standard(data) = viewModel.metadata {
                subtitle = data.subTitle.string
            }
            return viewModel.title + " " + subtitle
        }.joined(separator: "\n")
    }
}

extension BizumSplitExpensesSummaryPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumSplitExpensesSummaryPage {
        return BizumSplitExpensesSummaryPage()
    }

    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
