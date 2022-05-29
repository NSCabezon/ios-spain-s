//
//  OperabilityChangeSummaryPresenter.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

import Operative
import CoreFoundationLib

protocol OperabilityChangeSummaryPresenterProtocol: OperativeStepPresenterProtocol {
    var view: OperabilityChangeSummaryViewProtocol? { get set }
    func viewDidLoad()
    func finishOperativeSelected()
}

class OperabilityChangeSummaryPresenter {

    let dependenciesResolver: DependenciesResolver
    weak var view: OperabilityChangeSummaryViewProtocol?
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0

    lazy var operativeData: OperabilityChangeOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension OperabilityChangeSummaryPresenter: OperabilityChangeSummaryPresenterProtocol {
    var isBackable: Bool {
        false
    }
    
    func viewDidLoad() {
        setOperabilityText()
        view?.addFooterItems(self.buildFooter())
        trackScreen()
    }
    
    func setOperabilityText() {
        let operabilityText = operativeData.newOperabilityInd == .operative ? "personalArea_label_operative" : "personalArea_label_advisory"
        view?.setOperabilityText(operabilityText)
    }
    
    func finishOperativeSelected() {
        container?.stepFinished(presenter: self)
    }
    
    func buildFooter() -> [SummaryFooterItemViewModel] {
        let builder = OperabilityChangeSummaryFooterBuilder(operativeData: self.operativeData)
        builder.addGoToGlobalPosition(action: goToGlobalPosition)
        builder.addGoToOpinator(action: goToOpinator)
        return builder.build()
    }
    
    // MARK: - Actions
    
    func goToGlobalPosition() {
        self.container?.save(OperabilityChangeOperative.FinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        trackEvent(.opinator, parameters: [:])
        opinatorCapable.showOpinator()
    }
}

extension OperabilityChangeSummaryPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: OperabilitySummaryPage {
        return OperabilitySummaryPage()
    }
}
