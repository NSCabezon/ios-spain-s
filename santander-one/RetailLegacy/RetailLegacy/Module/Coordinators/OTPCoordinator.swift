//
//  LegacyOTPCoordinator.swift
//  RetailLegacy
//
//  Created by Luis Escámez Sánchez on 20/4/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI
import UIKit
import Account

public final class LegacyOTPCoordinator: BindableCoordinator {
    
    public weak var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public let dataBinding: DataBinding = DataBindingObject()
    private let dependenciesResolver: LegacyCoreDependenciesResolver
    
    init(dependenciesResolver: LegacyCoreDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func start() {
        guard let delegate: OtpScaAccountPresenterDelegate = dataBinding.get() else { return }
        let navigatorProvider: NavigatorProvider = dependenciesResolver.resolve()
        navigatorProvider.productHomeNavigator.goToLisboaAccountsOTP(delegate: delegate)
    }
}
