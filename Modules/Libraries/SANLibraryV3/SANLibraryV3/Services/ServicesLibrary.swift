//
//  ServicesLibrary.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 9/4/21.
//

import SANSpainLibrary
import CoreDomain
import SANLegacyLibrary
import SANServicesLibrary

public final class ServicesLibrary {
    
    // MARK: - Private attributes
    
    private let sessionStorage: Storage
    private var environment: EnvironmentRepresentable

    // MARK: - Public attributes
    public let configurationRepository: ConfigurationRepository

    // MARK: - Internal attributes
    let requestSemaphores: SANRequestSemaphores = SANRequestSemaphores()
    var networkClient: NetworkClient
    var bsanManagersProvider: BSANManagersProvider
    
    // MARK: - Public methods
    public init(networkClient: NetworkClient, environment: EnvironmentRepresentable, bsanManagersProvider: BSANManagersProvider, sessionStorage: Storage = MemoryStorage()) {
        self.networkClient = networkClient
        self.environment = environment
        self.configurationRepository = ConfigurationDataRepository(configuration: ConfigurationDto())
        self.bsanManagersProvider = bsanManagersProvider
        self.sessionStorage = sessionStorage
    }
}

extension ServicesLibrary: RepositoriesProvider {
    public var bizumRepository: BizumRepository {
        return BizumDataRepository(environmentProvider: self, networkManager: self.networkManager, storage: self.sessionStorage, requestSyncronizer: self, configurationRepository: self.configurationRepository)
    }
    public var loginRepository: LoginRepository {
        return LoginDataRepository(environmentProvider: self, networkManager: self.networkManager, storage: self.sessionStorage, requestSyncronizer: self)
    }
    public var sessionRepository: UserSessionRepository {
        return UserSessionDataRepository(storage: self.sessionStorage)
    }
    public var transfersRepository: SpainTransfersRepository {
        return TransfersDataRepository(environmentProvider: self, networkManager: self.networkManager, storage: self.sessionStorage, requestSyncronizer: self, configurationRepository: self.configurationRepository, bsanTransferManager: self.bsanManagersProvider.getBsanTransfersManager())
    }
    public var globalPositionRepository: SpainGlobalPositionRepository {
        return GlobalPositionNetworkRepository(
            storage: sessionStorage,
            bsanPGManager: bsanManagersProvider.getBsanPGManager()
        )
    }
    public var adobeTargetRepository: AdobeTargetRepository {
        return AdobeTargetDataRepository(environmentProvider: self, networkManager: self.networkManager, storage: self.sessionStorage, requestSyncronizer: self, configurationRepository: self.configurationRepository)
    }
    public var loansRepository: LoansDataRepository {
        return LoansDataRepository(environmentProvider: self, networkManager: self.networkManager, storage: self.sessionStorage, configurationRepository: self.configurationRepository)
    }
    public var loanReactiveRepository: LoanReactiveRepository {
        return LoanReactiveDataRepository(loanManager: bsanManagersProvider.getBsanLoansManager())
    }
    public var fundReactiveRepository: FundReactiveRepository {
        return FundReactiveDataRepository(fundManager: bsanManagersProvider.getBsanFundsManager())
    }
    public var onboardingRepository: OnboardingRepository {
        return SpainOnboardingRepository(pgManager: bsanManagersProvider.getBsanPGManager())
    }
    
    public var personalManagerReactiveRepository: PersonalManagerReactiveRepository {
        return PersonalManagerReactiveDataRepository(bsanManager: bsanManagersProvider.getBsanManagersManager())
    }
    
    public var personalManagerManagerNotificationReactiveRepository: PersonalManagerNotificationReactiveRepository {
        return PersonalManagerNotificationReactiveDataRepository(bsanNotificationManager: bsanManagersProvider.getManagerNotificationsManager())
    }
    public var santanderKeyOnboardingRepository: SantanderKeyOnboardingRepository {
        return SantanderKeyOnboardingDataRepository(environmentProvider: self, networkManager: self.networkManager, storage: self.sessionStorage, configurationRepository: self.configurationRepository)
    }
    public var carbonFootprintRepository: SpainCarbonFootprintRepository {
        return CarbonFootprintDataRepository(environmentProvider: self, networkManager: self.networkManager, configurationRepository: self.configurationRepository, storage: self.sessionStorage)
    }
    public var cardReactiveRepository: CardRepository {
         return CardReactiveDataRepository(cardManager: bsanManagersProvider.getBsanCardsManager())
	}
    public var financialHealthRepository: FinancialHealthSpainRepository {
        return FinancialHealthDataRepository(environmentProvider: self, networkManager: self.networkManager, storage: self.sessionStorage, requestSyncronizer: self, configurationRepository: self.configurationRepository)
    }
    public var userSessionFinancialHealthRepository: UserSessionFinancialHealthRepository {
        return UserSessionFinancialHealthDataRepository(storage: self.sessionStorage)
    }
}

extension ServicesLibrary: EnvironmentProvider {
    public func getEnvironment() -> EnvironmentRepresentable {
        return self.environment
    }
    
    public func update(environment: EnvironmentRepresentable) {
        self.environment = environment
    }
}

extension ServicesLibrary: ClientsProvider {
    public func update(client: NetworkClient) {
        self.networkClient = client
    }
}

private extension ServicesLibrary {
    var networkManager: NetworkClientManager {
        return NetworkClientManager(client: self.networkClient)
    }
}
