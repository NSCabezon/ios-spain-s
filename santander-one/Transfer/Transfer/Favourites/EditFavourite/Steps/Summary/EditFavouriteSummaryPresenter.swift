//
//  EditFavouriteSummaryPresenter.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 12/08/2021.
//

import Operative
import CoreFoundationLib

protocol EditFavouriteSummaryPresenterProtocol: OperativeSummaryPresenterProtocol {
    func close()
}

final class EditFavouriteSummaryPresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeSummaryViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = true
    var shouldShowProgressBar: Bool = false
    var container: OperativeContainerProtocol?
    lazy var operativeData: EditFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension EditFavouriteSummaryPresenter {
    func goToNewSend() {
        self.container?.save(EditFavouriteOperative.FinishingOption.home)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(EditFavouriteOperative.FinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
}

extension EditFavouriteSummaryPresenter: EditFavouriteSummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        let builder = EditFavouriteSummaryBuilder(operativeData: self.operativeData)
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
        self.container?.close()
    }
}

extension EditFavouriteSummaryPresenter: AutomaticScreenTrackable {
    var trackerPage: EditFavouriteSummaryPage {
        EditFavouriteSummaryPage()
    }

    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
