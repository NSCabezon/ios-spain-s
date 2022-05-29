import OpenCombine
import CoreDomain

protocol GetInternalTransferOriginAccountsUseCase {
    func fetchAccounts() -> AnyPublisher<GetInternalTransferOriginAccountsUseCaseOutput, Never>
}

struct GetInternalTransferOriginAccountsUseCaseOutput {
    let visibleAccounts: [AccountRepresentable]
    let notVisibleAccounts: [AccountRepresentable]
}

struct DefaultGetInternalTransferOriginAccountsUseCase {
    private let globalPositionRepository: GlobalPositionDataRepository
    public init(globalPositionRepository: GlobalPositionDataRepository) {
        self.globalPositionRepository = globalPositionRepository
    }
}

extension DefaultGetInternalTransferOriginAccountsUseCase: GetInternalTransferOriginAccountsUseCase {
    func fetchAccounts() -> AnyPublisher<GetInternalTransferOriginAccountsUseCaseOutput, Never> {
        return globalPositionRepository.getMergedGlobalPosition()
            .map { globalPosition in
                var visibles: [AccountRepresentable] = []
                var notVisibles: [AccountRepresentable] = []
                for account in globalPosition.accounts {
                    if account.isVisible {
                        visibles.append(account.product)
                    } else {
                        notVisibles.append(account.product)
                    }
                }
                return GetInternalTransferOriginAccountsUseCaseOutput(
                    visibleAccounts: visibles,
                    notVisibleAccounts: notVisibles
                )
            }
            .eraseToAnyPublisher()
    }
}
