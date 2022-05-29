//
//  SavingsCoordinator.swift
//  RetailLegacy
//
//  Created by Julio Nieto Santiago on 5/5/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI
import UIKit

public final class LegacySavingsShowPDFCoordinator: BindableCoordinator {
    
    public weak var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public let dataBinding: DataBinding = DataBindingObject()
    private let dependenciesResolver: LegacyCoreDependenciesResolver
    
    init(dependenciesResolver: LegacyCoreDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func start() {
        guard let data: Data = dataBinding.get() else { return }
        let navigatorProvider: NavigatorProvider = dependenciesResolver.resolve()
        navigatorProvider.productHomeNavigator.goToPdf(with: data, pdfSource: .unknown, toolbarTitleKey: "toolbar_title_listTransactions")
    }
}
