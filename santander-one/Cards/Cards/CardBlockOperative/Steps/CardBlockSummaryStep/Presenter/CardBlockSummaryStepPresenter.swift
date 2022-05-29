//
//  CardBlockSummaryStepPresenter.swift
//  Cards
//
//  Created by Laura González on 31/05/2021.
//

import Foundation
import Operative
import CoreFoundationLib

protocol CardBlockSummaryStepPresenterProtocol: OperativeSummaryPresenterProtocol {}

final class CardBlockSummaryStepPresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeSummaryViewProtocol?
    var summaryView: CardBlockSummaryStepViewProtocol? {
        return view as? CardBlockSummaryStepViewProtocol
    }
    var number: Int = 0
    var isBackButtonEnabled = false
    var isCancelButtonEnabled = false
    var shouldShowProgressBar = false
    var container: OperativeContainerProtocol?
    lazy var operativeData: CardBlockOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension CardBlockSummaryStepPresenter {
    func getViewModel() -> CardBlockSummaryViewModel {
        return CardBlockSummaryViewModel(operativeData: self.operativeData)
    }
    
    func buildView() {
        let builder = CardBlockSummaryStepBuilder(viewModel: getViewModel(), dependenciesResolver: dependenciesResolver)
        builder.addCardInformation()
        builder.addBlockReason()
        builder.addOperationDate()
        builder.addDelivery()
        builder.addGoToCardsHome(withAction: self.goToCardsHome)
        builder.addGoToGlobalPosition(withAction: self.goToGlobalPosition)
        builder.addHelpUsToImprove(withAction: self.goToHelpToImprove)
        let viewModel = builder.build()
        view?.setupStandardHeader(with: viewModel.header)
        view?.setupStandardBody(withItems: viewModel.bodyItems,
                                actions: viewModel.bodyActionItems,
                                collapsableSections: .noCollapsable)
        view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"),
                                           items: viewModel.footerItems)
        view?.build()
    }
    
    func goToCardsHome() {
        self.container?.save(CardBlockFinishingOption.cardsHome)
        container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(CardBlockFinishingOption.globalPosition)
        container?.stepFinished(presenter: self)
    }
    
    func goToHelpToImprove() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
}

extension CardBlockSummaryStepPresenter: CardBlockSummaryStepPresenterProtocol {
    func viewDidLoad() {
        self.buildView()
    }
}

extension CardBlockSummaryStepPresenter: AutomaticScreenTrackable {
    var trackerPage: CardBlockSummaryPage {
        return CardBlockSummaryPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
