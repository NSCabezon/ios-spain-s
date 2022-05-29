//
//  ProductsConfigurationSpies.swift
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

final class SetAnalysisAreaPreferencesUseCaseSpy: SetAnalysisAreaPreferencesUseCase {
    var setPreferencesUseCaseCalled: Bool = false

    struct SomeError: LocalizedError {
        var errorDescription: String?
    }

    func fetchSetFinancialPreferencesPublisher(preferences: SetFinancialHealthPreferencesRepresentable) -> AnyPublisher<Void, Error> {
        setPreferencesUseCaseCalled = true
        
        if preferences.preferencesProducts?.contains(where: { $0.preferencesData?.contains(where: { $0.productId?.isEmpty ?? true }) ?? true }) ?? true {
            return Fail(error: SomeError())
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

//final class AnalysisAreaProductsConfigurationSpy: AnalysisAreaProductsConfigurationCoordinator {
//    var navigationController: UINavigationController?
//    var onFinish: (() -> Void)?
//    var childCoordinators: [Coordinator]
//    var dataBinding: DataBinding
//    var goBackCalled = false
//    var openDeleteOtherBankCalled = false
//    
//    init() {
//        childCoordinators = []
//        dataBinding = DataBindingObject()
//    }
//    
//    func start() {}
//    
//    func back() {
//        goBackCalled = true
//    }
//    
//    func openDeleteOtherBank(bank: ProducListConfigurationOtherBanksRepresentable, updateWithDeletedBankOutsider: UpdateCompaniesOutsider) {
//        openDeleteOtherBankCalled = true
//    }
//    
//    func didTapContinue() {}
//    
//    func executeOffer(_ offer: OfferRepresentable) {}
//}
