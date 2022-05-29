//
//  HomeSpies.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 25/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreDomain
import OpenCombine
import CoreFoundationLib
@testable import Menu

final class GetAnalysisAreaSummaryUseCaseSpy: GetAnalysisAreaSummaryUseCase {
    var summaryUseCaseCalled: Bool = false
    
    func fechFinancialSummaryPublisher(products: GetFinancialHealthSummaryRepresentable) -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error> {
        summaryUseCaseCalled = true
        return Just([FinancialHealthSummaryItemRepresentableMock()])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

final class GetAnalysisAreaCompaniesWithProductsUseCaseSpy: GetAnalysisAreaCompaniesWithProductsUseCase {
    var companiesUseCaseCalled: Bool = false
    
    func fechFinancialCompaniesPublisher() -> AnyPublisher<[FinancialHealthCompanyRepresentable], Error> {
        companiesUseCaseCalled = true
        return Just([FinancialHealthCompanyRepresentableMock()])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

//final class GetAnalysisAreaProductsStatusUseCaseSpy: GetAnalysisAreaProductsStatusUseCase {
//    var productsStatusUseCaseCalled: Bool = false
//    
//    func fechFinancialProductsStatusPublisher() -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error> {
//        productsStatusUseCaseCalled = true
//        return Just(FinancialHealthProductsStatusRepresentableMock())
//            .setFailureType(to: Error.self)
//            .eraseToAnyPublisher()
//    }
//}

final class AnalysisAreaHomeCoordinatorSpy: AnalysisAreaCoordinator {
    var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator]
    var dataBinding: DataBinding
    var goBackCalled = false
    var openPrivateMenuCalled = false
    var openTooltipCalled = false
    var openChangeIntervalTimeCalled = false
    var openAddNewBankViewCalled = false
    var showProductsConfigurationCalled = false
    
    init() {
        childCoordinators = []
        dataBinding = DataBindingObject()
    }
    
    func start() {}
    
    func back() {
        goBackCalled = true
    }
    
    func openPrivateMenu() {
        openPrivateMenuCalled = true
    }
    
    func openTooltip(title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        openTooltipCalled = true
    }
    
    func openChangeIntervalTime(timeSelected: TimeSelectorRepresentable, timeOutsider: TimeSelectorOutsider) {
        openChangeIntervalTimeCalled = true
    }
    
    func openTotalizatorEditView() {}
    
    func openAddNewBankView() {
        openAddNewBankViewCalled = true
    }
    
    func showProductsConfiguration(companies: [FinancialHealthCompanyRepresentable], showUpdateError: Bool, productsStatus: FinancialHealthProductsStatusRepresentable?, updateOutsider: UpdateCompaniesOutsider) {
        showProductsConfigurationCalled = true
    }
    
    func openCategoryDetail(categoryDetailParameters: CategoryDetailParameters?) {
        fatalError()
    }
    
    func openSearchView() {
        
    }
    
    func showProductsConfiguration(info: FromHomeToProductsConfigurationInfo) {
        showProductsConfigurationCalled = true
    }
    
    func executeOffer(_ offer: OfferRepresentable) {
        openAddNewBankViewCalled = true
    }
}
