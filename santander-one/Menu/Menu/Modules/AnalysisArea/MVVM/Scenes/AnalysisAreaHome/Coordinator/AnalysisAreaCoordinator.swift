//  
//  AnalysisAreaCoordinator.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 4/1/22.
//

import Foundation
import UI
import QuartzCore
import CoreFoundationLib
import UIOneComponents
import CoreDomain

protocol AnalysisAreaCoordinator: BindableCoordinator {
    func back()
    func openPrivateMenu()
    func openSearchView()
    func openTooltip(title: LocalizedStylableText, subtitle: LocalizedStylableText)
    func openChangeIntervalTime(timeSelected: TimeSelectorRepresentable, timeOutsider: TimeSelectorOutsider)
    func openTotalizatorEditView()
    func openAddNewBankView()
    func showProductsConfiguration(info: FromHomeToProductsConfigurationInfo)
    func executeOffer(_ offer: OfferRepresentable)
    func openCategoryDetail(categoryDetailParameters: CategoryDetailParameters?)
}

final class DefaultAnalysisAreaCoordinator: AnalysisAreaCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: AnalysisAreaHomeExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    private lazy var bottomSheetTwoLabelsView: BottomSheetTwoLabelsView = {
        let view = BottomSheetTwoLabelsView(frame: .zero)
        return view
    }()
    
    public init(dependencies: AnalysisAreaHomeExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultAnalysisAreaCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: !UIAccessibility.isVoiceOverRunning)
    }
    
    func back() {
        navigationController?.popViewController(animated: !UIAccessibility.isVoiceOverRunning)
    }
    
    func openPrivateMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func openSearchView() {
        ToastCoordinator("Coming soon...").start()
    }
    
    func openTooltip(title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        guard let navigationController = navigationController else { return }
        bottomSheetTwoLabelsView.setTitle(title)
        bottomSheetTwoLabelsView.setSubtitle(subtitle)
        BottomSheet().show(in: navigationController, type: .custom(), component: .all, view: bottomSheetTwoLabelsView)
    }
    
    func openChangeIntervalTime(timeSelected: TimeSelectorRepresentable, timeOutsider: TimeSelectorOutsider) {
        let coordinator = dependencies.external.timeSelectorCoordinator()
        coordinator
            .set(timeSelected)
            .set(timeOutsider)
            .start()
        append(child: coordinator)
    }
    
    func openTotalizatorEditView() {
        ToastCoordinator("Open totalizator edit view").start()
    }
    
    func openAddNewBankView() {
        ToastCoordinator("Open add new back tapped").start()
    }
    
    func showProductsConfiguration(info: FromHomeToProductsConfigurationInfo) {
        let coordinator = dependencies.external.productsConfigurationCoordinator()
        coordinator
            .set(info)
            .start()
        append(child: coordinator)
    }
    
    func executeOffer(_ offer: OfferRepresentable) {
        let coordinator = dependencies.external.offersCoordinator()
        coordinator.dataBinding.set(offer)
        coordinator.start()
    }
    
    func openCategoryDetail(categoryDetailParameters: CategoryDetailParameters?) {
        let coordinator = dependencies.external.categoryDetailCoordinator()
        coordinator
            .set(categoryDetailParameters)
            .start()
        append(child: coordinator)
    }
}

private extension DefaultAnalysisAreaCoordinator {
    struct Dependency: AnalysisAreaHomeDependenciesResolver {
        let dependencies: AnalysisAreaHomeExternalDependenciesResolver
        let coordinator: AnalysisAreaCoordinator
        let dataBinding = DataBindingObject()
        
        var external: AnalysisAreaHomeExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> AnalysisAreaCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
