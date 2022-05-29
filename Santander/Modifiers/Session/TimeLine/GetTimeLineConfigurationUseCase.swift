import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadTimeLineConfigurationUseCase: UseCase<Void, LoadTimeLineConfigurationUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let bsanDataProvider: BSANDataProviderProtocol
    private let appRepository: AppRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.bsanDataProvider = self.dependenciesResolver.resolve()
        self.bsanManagersProvider = self.dependenciesResolver.resolve()
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadTimeLineConfigurationUseCaseOkOutput, StringErrorOutput> {
        guard let authCredentials = try? self.bsanDataProvider.getAuthCredentialsProvider(),
              let publicFileEnvironment = try? appRepository.getCurrentPublicFilesEnvironment().getResponseData(),
              let bsanEnvironment = try? bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData(),
              let urlBase = publicFileEnvironment.urlBase,
              let serviceSource = bsanEnvironment.microURL,
              let configurationURL = URL(string: urlBase + "apps/SAN/timeline/timeline-config-v2.json"),
              let serviceURL = URL(string: serviceSource + "/api/v1/lisboa/envioPagos/"),
              let timelineToken = authCredentials.timelineToken
        else { return .error(StringErrorOutput(nil)) }
        return .ok(LoadTimeLineConfigurationUseCaseOkOutput(token: timelineToken, serviceURL: serviceURL, configurationURL: configurationURL))
    }
}

struct LoadTimeLineConfigurationUseCaseOkOutput {
    let token: String
    let serviceURL: URL
    let configurationURL: URL
}
