import OpenCombine
import CoreDomain

public protocol GetInternalTransferOriginAccountsFilteredUseCase {
    func filterAccounts(input: GetInternalTransferOriginAccountsUseCaseInput) -> AnyPublisher<GetInternalTransferOriginAccountsFilteredUseCaseOutput, Never>
}

public struct GetInternalTransferOriginAccountsUseCaseInput {
    public let visibleAccounts: [AccountRepresentable]
    public let notVisibleAccounts: [AccountRepresentable]
    
    public init(visibleAccounts: [AccountRepresentable], notVisibleAccounts: [AccountRepresentable]) {
        self.visibleAccounts = visibleAccounts
        self.notVisibleAccounts = notVisibleAccounts
    }
}

public struct GetInternalTransferOriginAccountsFilteredUseCaseOutput {
    public let visiblesFiltered: [AccountRepresentable]
    public let notVisiblesFiltered: [AccountRepresentable]
    
    public init(visiblesFiltered: [AccountRepresentable],
                notVisiblesFiltered: [AccountRepresentable]) {
        self.visiblesFiltered = visiblesFiltered
        self.notVisiblesFiltered = notVisiblesFiltered
    }
}

struct DefaultGetInternalTransferOriginAccountsFilteredUseCase {}

extension DefaultGetInternalTransferOriginAccountsFilteredUseCase: GetInternalTransferOriginAccountsFilteredUseCase {
    func filterAccounts(input: GetInternalTransferOriginAccountsUseCaseInput) -> AnyPublisher<GetInternalTransferOriginAccountsFilteredUseCaseOutput, Never> {
        return Just(
            GetInternalTransferOriginAccountsFilteredUseCaseOutput(
                visiblesFiltered: input.visibleAccounts,
                notVisiblesFiltered: input.notVisibleAccounts
            )
        )
            .eraseToAnyPublisher()
    }
}
