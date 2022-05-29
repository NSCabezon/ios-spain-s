//
//  LoanTransactionDetailCoordinator.swift
//  RetailLegacy
//
//  Created by Juan Carlos López Robles on 1/20/22.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import PdfCommons
import Loans

public final class LoanTransactionDetailActionsCoordinator: BindableCoordinator {
    public var onFinish: (() -> Void)?
    public var dataBinding: DataBinding = DataBindingObject()
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController?
    private let dependencies: RetailLegacyLoanExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()

    public init(dependencies: RetailLegacyLoanExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func start() {
        guard let loanRepresentable: LoanRepresentable = dataBinding.get(),
              let action: LoanTransactionDetailActionType = dataBinding.get()
        else { return }
        let loan = LoanEntity(loanRepresentable)
        let coordinator = legacyDependencies.resolve(for: LoansHomeCoordinatorNavigator.self)
        switch action {
        case .partialAmortization:
            goToPartialAmortization(loan)
        case .changeAccount:
            coordinator.didSelectChangeLinkedAccount(for: loan)
        case let .pdfExtract(data):
            showPDF(data)
        default:
            break
        }
    }
    
    private func showPDF(_ data: Data?, title: String = "toolbar_title_movesDetail", source: PdfSource = .unknown) {
        guard let data = data else { return }
        let pdfLauncher = self.legacyDependencies.resolve(for: PDFCoordinatorLauncher.self)
        pdfLauncher.openPDF(data, title: localized(title), source: source)
    }
    
    private func goToPartialAmortization(_ loan: LoanEntity) {
        let navigatorProvider = self.legacyDependencies.resolve(for: NavigatorProvider.self)
        navigatorProvider.loanDetailNavigator.gotoPartialAmortization(for: loan)
    }
}

