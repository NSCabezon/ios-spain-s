//
//  TipListPresenter.swift
//  Menu
//
//  Created by Margaret on 04/08/2020.

import Foundation
import CoreFoundationLib

protocol TipListPresenterProtocol: MenuTextWrapperProtocol {
    var view: TipListViewProtocol? { get set }
    var coordinatorDelegate: TipListCoordinatorDelegate? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectTip(offerId: String)
}

class TipListPresenter {
    weak var view: TipListViewProtocol?
    weak var coordinatorDelegate: TipListCoordinatorDelegate?
    let dependenciesResolver: DependenciesResolver

    init(resolver: DependenciesResolver) {
        self.dependenciesResolver = resolver
    }
}

extension TipListPresenter: TipListPresenterProtocol {
    func viewDidLoad() {
        let homeTips = self.dependenciesResolver.resolve(for: HomeTipsConfiguration.self)
        let tips: [TipDetailViewModel] = homeTips.tips.map({ tip -> TipDetailViewModel in
            return TipDetailViewModel(title: tip.title,
                                      description: tip.description,
                                      offerId: tip.offerId ?? "",
                                      image: tip.icon,
                                      baseUrl: tip.baseUrl,
                                      tag: tip.tag)
        }) 
        trackScreen()
        view?.showTitle(homeTips.section)
        view?.showTipList(viewModels: tips)
    }

    func didSelectDismiss() {
        self.coordinatorDelegate?.didSelectDismiss()
    }
    func didSelectMenu() {
        self.coordinatorDelegate?.didSelectMenu()
    }

    func didSelectTip(offerId: String) {
        let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        guard let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else { return }

        self.trackEvent(.selected, parameters: [TrackerDimension.offerId: offerId])
        self.coordinatorDelegate?.didSelectOfferNodrawer(offerDTO)
    }
}

extension TipListPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve()
    }

    var trackerPage: TipListPage { TipListPage() }
}
