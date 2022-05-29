//
//  InternalTransferOperativeCoordinator.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import CoreFoundationLib
import UIOneComponents
import OpenCombine
import Operative
import UIKit
import UI

public enum InternalTransferStep: Equatable {
    case selectAccount
    case destinationAccount
    case amount
    case confirmation
    case summary
}

public protocol InternalTransferOperativeCoordinator: OperativeCoordinator {
    var stepsCoordinator: StepsCoordinator<InternalTransferStep> { get }
    var progress: Progress { get }
    func back(to step: InternalTransferStep)
    func showInternalTransferError(_ error: InternalTransferOperativeError)
    func goToDownloadPDF()
    func goToShareImage()
    func goToSendMoneyHome()
    func goToGlobalPosition()
    func showSuccessOpinator()
}

public final class DefaultInternalTransferOperativeCoordinator {
    weak public var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    private let externalDependencies: InternalTransferOperativeExternalDependenciesResolver
    public var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    var operative: InternalTransferOperative {
        return dependencies.resolve()
    }
    
    private lazy var dependencies: Dependency = {
        Dependency(external: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: InternalTransferOperativeExternalDependenciesResolver) {
        self.navigationController = dependencies.resolve()
        self.externalDependencies = dependencies
    }
}

extension DefaultInternalTransferOperativeCoordinator: InternalTransferOperativeCoordinator {
    public var stepsCoordinator: StepsCoordinator<InternalTransferStep> {
        return dependencies.resolve()
    }
    
    public var progress: Progress {
        operative.progress
    }
    
    public func dismiss() {
        stepsCoordinator.finish()
    }
    
    public func start() {
        operative.start()
    }
    
    public func next() {
        operative.next()
    }
    
    public func back() {
        operative.back()
    }
    
    public func back(to step: InternalTransferStep) {
        operative.back(to: step)
    }
    
    public func showInternalTransferError(_ error: InternalTransferOperativeError) {
        guard let navigation = navigationController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation,
                         type: .custom(isPan: true),
                         component: .all,
                         view: didSendMoneyCannotOperationViewInBottomSheet(bottomSheet: bottomSheet,
                                                                            error: error)
        )
    }
    
    public func goToDownloadPDF() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    public func goToShareImage() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    public func goToSendMoneyHome() {
        dismiss()
    }
    
    public func goToGlobalPosition() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    public func showSuccessOpinator() {
        let info = GiveUpOpinatorInfoEntity(path: "app-traspasos-exito")
        let onSuccess: () -> Void = { [weak self] in
            self?.operative.back()
        }
        let coordinator = opinatorCoordinator
            .set(info)
            .set(onSuccess)
        coordinator.start()
    }
    
    public var opinatorCoordinator: BindableCoordinator {
        return dependencies.external.opinatorCoordinator()
    }
}

private extension DefaultInternalTransferOperativeCoordinator {
    final class Dependency: InternalTransferOperativeDependenciesResolver {
        let external: InternalTransferOperativeExternalDependenciesResolver
        unowned let coordinator: InternalTransferOperativeCoordinator
        let dataBinding = DataBindingObject()
        lazy var operative: InternalTransferOperative = {
            return InternalTransferOperative(dependencies: self)
        }()
        lazy var stepsCoordinator: StepsCoordinator<InternalTransferStep> = {
            return StepsCoordinator(
                navigationController: external.resolve(),
                provider: { [unowned self] step in
                    return self.stepProvider(for: step)},
                steps: InternalTransferOperative.steps
            )
        }()
        
        init(external: InternalTransferOperativeExternalDependenciesResolver, coordinator: InternalTransferOperativeCoordinator) {
            self.external = external
            self.coordinator = coordinator
        }
        
        func resolve() -> InternalTransferOperativeCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> StepsCoordinator<InternalTransferStep> {
            return stepsCoordinator
        }
        
        func resolve() -> InternalTransferOperative {
            return operative
        }
        
        func resolve() -> InternalTransferAccountSelectorDependenciesResolver {
            return InternalTransferAccountSelectorDependency(dependencies: external,
                                                             dataBinding: resolve(),
                                                             coordinator: resolve(),
                                                             operative: resolve())
        }
        
        func resolve() -> InternalTransferDestinationAccountDependenciesResolver {
            return InternalTransferDestinationAccountDependency(dependencies: external,
                                                                dataBinding: resolve(),
                                                                coordinator: resolve(),
                                                                operative: resolve())
        }
        
        func resolve() -> InternalTransferAmountDependenciesResolver {
            return InternalTransferAmountDependency(dependencies: external,
                                                    dataBinding: resolve(),
                                                    coordinator: resolve(),
                                                    operative: resolve())
        }
        
        func resolve() -> InternalTransferConfirmationDependenciesResolver {
            return InternalTransferConfirmationDependency(dependencies: external,
                                                          dataBinding: resolve(),
                                                          coordinator: resolve(),
                                                          operative: resolve())
        }
        
        func resolve() -> InternalTransferSummaryDependenciesResolver {
            return InternalTransferSummaryDependency(dependencies: external,
                                                     dataBinding: resolve(),
                                                     coordinator: resolve(),
                                                     operative: resolve())
        }
        
        func stepProvider(for step: InternalTransferStep) -> StepIdentifiable {
            switch step {
            case .selectAccount:
                let dependencies: InternalTransferAccountSelectorDependenciesResolver = resolve()
                let internalTransferAccountSelectorViewController: InternalTransferAccountSelectorViewController = dependencies.resolve()
                return internalTransferAccountSelectorViewController
            case .destinationAccount:
                let dependencies: InternalTransferDestinationAccountDependenciesResolver = resolve()
                let internalTransferDestinationAccountSelectorViewController: InternalTransferDestinationAccountViewController = dependencies.resolve()
                return internalTransferDestinationAccountSelectorViewController
            case .amount:
                let dependencies: InternalTransferAmountDependenciesResolver = resolve()
                let viewController: InternalTransferAmountViewController = dependencies.resolve()
                return viewController
            case .confirmation:
                let dependencies: InternalTransferConfirmationDependenciesResolver = resolve()
                let viewController: InternalTransferConfirmationViewController = dependencies.resolve()
                return viewController
            case .summary:
                let dependencies: InternalTransferSummaryDependenciesResolver = resolve()
                let viewController: InternalTransferSummaryViewController = dependencies.resolve()
                return viewController
            }
        }
    }
}

private extension DefaultInternalTransferOperativeCoordinator {
    func didSendMoneyCannotOperationViewInBottomSheet(bottomSheet: BottomSheet, error: InternalTransferOperativeError) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let sendMoneyCannotOperationView = InternalTransferLaunchErrorView()
        sendMoneyCannotOperationView.setSubtitle(error)
        guard let navigation = navigationController else { return UIView() }
        sendMoneyCannotOperationView.didTapOnAccept = {
            bottomSheet.close(navigation)
        }
        view.addSubview(sendMoneyCannotOperationView)
        sendMoneyCannotOperationView.fullFit()
        view.sizeToFit()
        return view
    }
}
