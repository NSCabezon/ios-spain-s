//
//  CardOnOffSummaryStepPresenter.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import CoreFoundationLib
import Operative

protocol CardOnOffSummaryStepPresenterProtocol: OperativeSummaryPresenterProtocol {
    func close()
}

final class CardOnOffSummaryStepPresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeSummaryViewProtocol?
    var summaryView: CardOnOffSummaryStepViewProtocol? {
        return view as? CardOnOffSummaryStepViewProtocol
    }
    var number: Int = 0
    var isBackButtonEnabled = false
    var isCancelButtonEnabled = false
    var shouldShowProgressBar = false
    var container: OperativeContainerProtocol?
    lazy var operativeData: CardOnOffOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension CardOnOffSummaryStepPresenter {
    func getViewModel() -> CardOnOffSummaryViewModel {
        return CardOnOffSummaryViewModel(operativeData: self.operativeData)
    }
    
    func buildView() {
        let builder = CardOnOffSummaryStepBuilder(viewModel: getViewModel(), dependenciesResolver: dependenciesResolver)
        builder.addCardInformation()
        builder.addOperationDate()
        builder.addGoToCardsHome(withAction: self.goToCardsHome)
        builder.addGoToGlobalPosition(withAction: self.goToGlobalPosition)
        builder.addHelpUsToImprove(withAction: self.goToHelpToImprove)
        let viewModel = builder.build()
        view?.setupStandardHeader(with: viewModel.header)
        view?.setupStandardBody(withItems: viewModel.bodyItems,
                                actions: viewModel.bodyActionItems,
                                collapsableSections: .noCollapsable)
        view?.setupStandardFooterWithTitle(localized("summary_label_nowThat"),
                                           items: viewModel.footerItems)
        view?.build()
    }
    
    func goToCardsHome() {
        self.container?.save(CardOnOffFinishingOption.cardsHome)
        container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(CardOnOffFinishingOption.globalPosition)
        container?.stepFinished(presenter: self)
    }
    
    func goToHelpToImprove() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
}

extension CardOnOffSummaryStepPresenter: CardOnOffSummaryStepPresenterProtocol {
    func viewDidLoad() {
        self.buildView()
    }

    func close() {
        self.container?.save(CardOnOffFinishingOption.operativeFinished)
        self.container?.stepFinished(presenter: self)
    }
}

extension CardOnOffSummaryStepPresenter: AutomaticScreenTrackable {
    var trackerPage: CardOnOffSummaryPage {
        return operativeData.option == .turnOn ? CardOnOffSummaryPage(page: CardOnSummaryPage().page) : CardOnOffSummaryPage(page: CardOffSummaryPage().page)
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
