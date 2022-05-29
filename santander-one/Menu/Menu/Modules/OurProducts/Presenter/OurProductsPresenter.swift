//
//  OurProductsPresenter.swift
//  Menu
//
//  Created by alvola on 29/04/2020.
//

import CoreFoundationLib

protocol OurProductsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: OurProductsViewProtocol? { get set }
    func viewDidLoad()
    func didPressDrawer()
    func didPressClose()
    func didSelectIndex(_ idx: Int)
    func didSelectAccept()
}

final class OurProductsPresenter {
    weak var view: OurProductsViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var info: [PublicProduct]? {
        didSet { self.setProductViewModels() }
    }
    
    private var delegate: PublicMenuCoordinatorDelegate {
        return dependenciesResolver.resolve(for: PublicMenuCoordinatorDelegate.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var loadPublicProductsUseCase: LoadPublicProductsUseCase {
        return self.dependenciesResolver.resolve(for: LoadPublicProductsUseCase.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
         return dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var coordinator: OurProductsCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: OurProductsCoordinatorProtocol.self)
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension OurProductsPresenter: OurProductsPresenterProtocol {
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
        if let info = info, info.count > idx, let url = info[idx].absoluteUrl {
            delegate.toggleSideMenu()
            delegate.openUrl(url)
        }
    }
    
    func didSelectAccept() {
        self.coordinator.close()
    }
}

private extension OurProductsPresenter {
    func loadPublicProduct() {
        UseCaseWrapper(
            with: loadPublicProductsUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.info = result.publicProducts?.publicProducts
                self?.view?.hideLoadingView(completion: nil)
            }, onError: { [weak self] _ in
                self?.view?.hideLoadingView {
                    self?.coordinator.showDialog()
                }
        })
    }
    
    private func setProductViewModels() {
        let info = self.info ?? []
        self.view?.setOurProductsModels(info.map {
            ButtonViewModel(titleKey: $0.text ?? "",
                            iconKey: (baseURLProvider.baseURL ?? "").dropLast(1) + ($0.icon ?? "")
            )})
    }
}
