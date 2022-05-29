//
//  FullScreenBannerPresenter.swift
//  UI
//
//  Created by Cristobal Ramos Laina on 24/04/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol FullScreenBannerPresenterProtocol: AnyObject {
    var view: FullScreenBannerViewProtocol? { get set }
    func dismiss()
    func viewDidLoad()
    func execute(offerAction: OfferActionRepresentable)
    func didTapOnClose()
}

final class FullScreenBannerPresenter {
    weak var view: FullScreenBannerViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    var expireOfferUseCase: ExpirePullOfferUseCase {
        return self.dependenciesResolver.resolve(for: ExpirePullOfferUseCase.self)
    }
}

private extension FullScreenBannerPresenter {
    var coordinator: FullScreenBannerCoordinatorProtocol {
        return self.dependenciesResolver.resolve()
    }
    var offer: PullOfferFullScreenBannerConfiguration {
        return self.dependenciesResolver.resolve()
    }
    var floatingBannerCloseDelegate: FloatingBannerCloseDelegate {
        return self.dependenciesResolver.resolve()
    }
    
    func createViewModel() -> FullScreenBannerViewModel {
        let viewModel = FullScreenBannerViewModel(banner: offer.banner, action: offer.action, time: offer.time, transparentClosure: offer.transparentClosure)
        return viewModel
    }
}

extension FullScreenBannerPresenter: FullScreenBannerPresenterProtocol {
    func execute(offerAction: OfferActionRepresentable) {
        self.coordinator.execute(offerAction: offerAction)
    }
    
    func dismiss() {
        self.coordinator.dismiss { [weak self] in
            self?.floatingBannerCloseDelegate.didCloseFloatingBanner()
        }
    }
    
    func didTapOnClose() {
        UseCaseWrapper(
            with: self.expireOfferUseCase.setRequestValues(requestValues: ExpirePullOfferUseCaseInput(offerId: offer.offerId)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self))
        self.dismiss()
    }
   
    func viewDidLoad() {
        view?.configureView(viewModel: createViewModel())
    }
}
