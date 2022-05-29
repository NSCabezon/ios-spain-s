//
//  BizumAcceptRequestPresenter.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 03/12/2020.
//

import Foundation
import CoreFoundationLib
import Operative

protocol BizumAcceptRequestSummaryPresenterProtocol: OperativeSummaryPresenterProtocol {}

extension BizumAcceptRequestSummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

final class BizumAcceptRequestSummaryPresenter {
    weak var view: OperativeSummaryViewProtocol?
    var bizumView: BizumSummaryViewProtocol? {
        view as? BizumSummaryViewProtocol
    }
    let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    lazy var operativeData: BizumAcceptMoneyRequestOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumAcceptRequestSummaryPresenter: BizumAcceptRequestSummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        let viewModel = buildSummaryAddingAmount(true)
        self.view?.setupStandardHeader(with: viewModel.header)
        self.bizumView?.setupBizumBody(viewModel.bodyItems, actions: viewModel.bodyActionItems, showLastSeparator: true, shareViewModel: nil, whatsAppAction: nil)
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
    }
}

private extension BizumAcceptRequestSummaryPresenter {
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
    
    func buildSummaryAddingAmount(_ addingAmount: Bool) -> OperativeSummaryBizumViewModel {
        let builder = BizumAcceptRequestSummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addOriginAccountAddingAmount(addingAmount)
        builder.addTransferType()
        builder.addComment()
        builder.addDestinationBizumContacts()
        builder.addShare(withAction: share)
        builder.addGoToBizumHome(withAction: goToBizumHome)
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addGoToOpinator(withAction: goToOpinator)
        }
        return builder.build()
    }
}

extension BizumAcceptRequestSummaryPresenter: Shareable {
    func getShareableInfo() -> String {
        trackEvent(.share, parameters: [:])
        let model = buildSummaryAddingAmount(false)
        var textToShare = "\(model.header.title)\n\(model.header.description)\n"
        textToShare += model.bodyItems.map { viewModel in
            var subtitle = ""
            if case let .standard(data) = viewModel.metadata {
                subtitle = data.subTitle.string
                if let info = data.info {
                    subtitle += " - \(info)"
                }
            } else if case let .recipients(list: data) = viewModel.metadata {
                subtitle += data.map({ $0.name }).joined(separator: " - ")
            }
            return viewModel.title + ": " + subtitle
        }.joined(separator: "\n")
        return textToShare
    }
}

extension BizumAcceptRequestSummaryPresenter: AutomaticScreenActionTrackable {
    var trackerPage: BizumAcceptMoneyResumePage {
        BizumAcceptMoneyResumePage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }

    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
