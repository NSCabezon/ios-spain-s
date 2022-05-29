import CoreFoundationLib

protocol PersistedUserCheckable: class {
    associatedtype T: PublicNavigatable
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    var navigator: T { get }
}

extension PersistedUserCheckable {
    func checkHasPersistedUser() {
        UseCaseWrapper(with: useCaseProvider.getCheckPersistedUserUseCase(), useCaseHandler: useCaseHandler, errorHandler: nil,
                       onSuccess: { [weak self] _ in
                        self?.existsPersistedUser(true)
        }, onError: { [weak self] (_) in
            self?.existsPersistedUser(false)
        })
    }
    
    func existsPersistedUser(_ persistedUser: Bool) {
        navigator.goToPublic(shouldGoToRememberedLogin: persistedUser)
    }
}
