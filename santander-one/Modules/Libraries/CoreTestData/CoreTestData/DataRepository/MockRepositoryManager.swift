import CoreFoundationLib
import CoreDomain

public final class MockRepositoryManager {
    private let dependencies: DependenciesInjector & DependenciesResolver
    private let mockDataInjector: MockDataInjector
    private var bankingUtils: BankingUtils?
    
    public init(dependencies: DependenciesInjector & DependenciesResolver, mockDataInjector: MockDataInjector) {
        self.dependencies = dependencies
        self.mockDataInjector = mockDataInjector
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: PullOffersConfigRepositoryProtocol.self) { _ in
            return MockPullOffersConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: LoadingTipsRepositoryProtocol.self) { _ in
            return MockLoadingTipsRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: TricksRepositoryProtocol.self) { _ in
            return MockTricksRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: ComingFeaturesRepositoryProtocol.self) { _ in
            return MockComingFeaturesRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: TricksRepositoryProtocol.self) { _ in
            return MockTricksRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: FaqsRepositoryProtocol.self) { _ in
            return MockFaqsRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: SepaInfoRepositoryProtocol.self) { _ in
            return MockSepaInfoRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: OneAuthorizationProcessorRepository.self) { _ in
            return MockOapRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: TransfersRepository.self) { _ in
            return MockTransfersRepository(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: BankingUtilsProtocol.self) { _ in
            if self.bankingUtils == nil {
                self.bankingUtils = BankingUtils(dependencies: self.dependencies)
            }
            return self.bankingUtils ?? BankingUtils(dependencies: self.dependencies)
        }
        self.dependencies.register(for: HomeTipsRepository.self) { _ in
            return MockHomeTipsRepository()
        }
        self.dependencies.register(for: PublicMenuRepository.self) { _ in
            return PublicMenuRepositoryMock()
        }
        self.dependencies.register(for: SegmentedUserRepository.self) { _ in
            return MockSegmentedUserRepository(mockDataInjector: self.mockDataInjector)
        }
    }
}

