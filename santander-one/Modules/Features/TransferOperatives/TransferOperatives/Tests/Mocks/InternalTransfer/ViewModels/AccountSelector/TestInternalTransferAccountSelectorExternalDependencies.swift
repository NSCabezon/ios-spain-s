@testable import TransferOperatives
import CoreFoundationLib
import CoreDomain

struct TestInternalTransferAccountSelectorExternalDependencies: InternalTransferAccountSelectorExternalDependenciesResolver {
    var accountRepresentables: [AccountRepresentable]
    var trackerManager: TrackerManager

    init(accounts: [AccountRepresentable], trackerManager: TrackerManager) {
        self.accountRepresentables = accounts
        self.trackerManager = trackerManager
    }

    func resolve() -> UINavigationController {
        fatalError()
    }

    func resolve() -> AccountNumberFormatterProtocol? {
        return nil
    }

    func resolve() -> GlobalPositionDataRepository {
        return TestGlobalPositionDataRepository(accounts: accountRepresentables)
    }

    func resolve() -> AccountNumberFormatterProtocol {
        fatalError()
    }

    func resolve() -> TrackerManager {
        return trackerManager
    }
}
