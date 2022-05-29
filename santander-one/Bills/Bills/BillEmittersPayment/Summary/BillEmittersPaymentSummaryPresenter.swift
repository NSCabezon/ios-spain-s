//
//  BillEmittersPaymentSummaryPresenter.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 25/05/2020.
//

import Operative
import CoreFoundationLib
import UI

protocol BillEmittersPaymentSummaryPresenterProtocol: OperativeSummaryPresenterProtocol {}

extension BillEmittersPaymentSummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
    
    var isBackable: Bool {
        false
    }
}

final class BillEmittersPaymentSummaryPresenter {
    weak var view: OperativeSummaryViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var operativeData: BillEmittersPaymentOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BillEmittersPaymentSummaryPresenter: BillEmittersPaymentSummaryPresenterProtocol {
    
    func viewDidLoad() {
        self.trackScreen()
        let builder = BillEmittersPaymentSummaryBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmount()
        builder.addOriginAccount()
        builder.addType()
        builder.addEmitter()
        builder.addEmitterCode()
        builder.addItems()
        builder.addDate()
        builder.addShare(withAction: share)
        builder.addGoToBillsHome(withAction: goToBillsHome)
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addGoToOpinator(withAction: goToOpinator)
        }
        let viewModel = builder.build()
        self.view?.setupStandardHeader(with: viewModel.header)
        self.view?.setupStandardBody(
            withItems: viewModel.bodyItems,
            actions: viewModel.bodyActionItems,
            collapsableSections: .defaultCollapsable(visibleSections: 3)
        )
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
    }
}

private extension BillEmittersPaymentSummaryPresenter {
    
    func share() {
        self.container?.coordinator.share(self, type: .text)
    }
    
    func goToBillsHome() {
        self.container?.save(BillEmittersPaymentOperative.FinishingOption.billsHome)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(BillEmittersPaymentOperative.FinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
}

extension BillEmittersPaymentSummaryPresenter: Shareable {
    
    func getShareableInfo() -> String {
        trackEvent(.share, parameters: [:])
        let builder = BillEmittersPaymentSummaryBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmount()
        builder.addType()
        builder.addEmitter()
        builder.addEmitterCode()
        builder.addItems()
        builder.addDate()
        return builder.build().bodyItems.map { viewModel in
            viewModel.title + " " + viewModel.subTitle.string
        }.joined(separator: "\n")
    }
}

extension BillEmittersPaymentSummaryPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: BillEmittersPaymentSummaryPage {
        BillEmittersPaymentSummaryPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
