//
//  ApplePayWelcomePresenter.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 11/12/2019.
//

import Foundation
import CoreFoundationLib

protocol ApplePayWelcomePresenterProtocol: AnyObject {
    var view: ApplePayWelcomeViewProtocol? { get set }
    func didSelectDismiss()
    func didSelectApplePay()
    func viewDidLoad()
}

class ApplePayWelcomePresenter {
    
    weak var view: ApplePayWelcomeViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private weak var coordinator: ApplePayWelcomeCoordinator?
    
    init(dependenciesResolver: DependenciesResolver, coordinator: ApplePayWelcomeCoordinator) {
        self.dependenciesResolver = dependenciesResolver
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        self.trackScreen()
    }
}

extension ApplePayWelcomePresenter: ApplePayWelcomePresenterProtocol {
    
    func didSelectDismiss() {
        self.coordinator?.dismiss()
    }
    
    func didSelectApplePay() {
        self.coordinator?.goToApplePay()
        self.trackEvent(.wallet, parameters: [:])
    }
}

extension ApplePayWelcomePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: ApplePayPage {
        return ApplePayPage()
    }
}
