//
//  StockholdersPresenter.swift
//  Menu
//
//  Created by alvola on 28/04/2020.
//

import CoreFoundationLib

protocol StockholdersPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: StockholdersViewProtocol? { get set }
    func viewDidLoad()
    func didPressDrawer()
    func didPressClose()
    func didSelectIndex(_ idx: Int)
    func didSelectAccept()
}

final class StockholdersPresenter {
    weak var view: StockholdersViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var info: [PublicProduct]? {
        didSet { self.setStockholdersModels() }
    }
    private var delegate: PublicMenuCoordinatorDelegate {
        return dependenciesResolver.resolve(for: PublicMenuCoordinatorDelegate.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var loadPublicProductsUseCase: LoadPublicProductsUseCase {
        return self.dependenciesResolver.resolve(for: LoadPublicProductsUseCase.self)
    }
    
    private var coordinator: StockholdersCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: StockholdersCoordinatorProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension StockholdersPresenter: StockholdersPresenterProtocol {
    func viewDidLoad() {
        self.view?.setLoadingView { [weak self] in
            self?.loadPublicProduct()
        }
    }
    
    func didPressDrawer() {
        delegate.toggleSideMenu()
    }
    
    func didPressClose() {
        coordinator.close()
    }
    
    func didSelectIndex(_ idx: Int) {
        if let info = info, info.count > idx, let url = info[idx].absoluteUrl, !url.isEmpty {
            delegate.toggleSideMenu()
            delegate.openUrl(url)
        }
    }
    
    func didSelectAccept() {
        self.coordinator.close()
    }
}

private extension StockholdersPresenter {
    func loadPublicProduct() {
        UseCaseWrapper(
            with: loadPublicProductsUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.info = result.publicProducts?.stockHolders
                self?.view?.hideLoadingView(completion: nil)
            }, onError: { [weak self] _ in
                self?.view?.hideLoadingView {
                    self?.coordinator.showDialog()
                }
        })
    }
    
    private func setStockholdersModels() {
        let info = self.info ?? []
        self.view?.setStockholdersModels(info.map {
            ButtonViewModel(
                titleKey: $0.text ?? "",
                iconKey: (baseURLProvider.baseURL ?? "").dropLast(1) + ($0.icon ?? ""))
        })
    }
}
