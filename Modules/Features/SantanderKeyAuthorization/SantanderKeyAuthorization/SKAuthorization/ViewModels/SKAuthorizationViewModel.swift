import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import Operative
import SANSpainLibrary

public enum AuthorizationState: State {
    case idle
    case showLoading(Bool)
    case showError(OneOperativeAlertErrorViewData?)
}

final class SKAuthorizationViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKAuthorizationDependenciesResolver
    private let stateSubject = CurrentValueSubject<AuthorizationState, Never>(.idle)
    var state: AnyPublisher<AuthorizationState, Never>

    init(dependencies: SKAuthorizationDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }

    func viewDidLoad() {}

    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension SKAuthorizationViewModel {
    var coordinator: SKAuthorizationCoordinator {
        return dependencies.resolve()
    }
}

// MARK: - Subscriptions

private extension SKAuthorizationViewModel {}

// MARK: - Publishers

private extension SKAuthorizationViewModel {}
