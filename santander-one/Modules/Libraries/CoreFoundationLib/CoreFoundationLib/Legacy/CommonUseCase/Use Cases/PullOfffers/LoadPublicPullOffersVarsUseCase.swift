import Foundation
import SANLegacyLibrary

public class LoadPublicPullOffersVarsUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let appRepository: AppRepositoryProtocol
    private let pullOffersEngine: EngineInterface
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.pullOffersEngine = self.dependenciesResolver.resolve(for: EngineInterface.self)
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let calendar = Calendar(identifier: .gregorian)
        let hasPersistedUser = try appRepository.hasPersistedUser().getResponseData() ?? false
        let persistedUser = try? appRepository.getPersistedUser().getResponseData()
        let isPb = (try? checkRepositoryResponse(provider.getBsanSessionManager().isPB())).flatMap({ $0 }) ?? false
        let clientSegment: String = {
            if isPb {
                return "PB"
            } else {
                return persistedUser?.bdpCode.flatMap(getEscapedString) ?? ""
            }
        }()
        let commercialSegment: String = {
            if isPb {
                return "PB"
            } else {
                return persistedUser?.comCode.flatMap(getEscapedString) ?? ""
            }
        }()
        let bundleVersion: Int = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "") ?? 0
        pullOffersEngine.addRules(rules: [
            "SYS": getEscapedString(string: "ios"),
            "VCODE": bundleVersion,
            "GDM": calendar.component(.day, from: Date()),
            "GDS": calendar.component(.weekday, from: Date())-1,
            "GMA": calendar.component(.month, from: Date()),
            "GMY": calendar.component(.year, from: Date()),
            "TODAY": "'\(PullOffersTimeManager.toStringFromCurrentLocale(date: Date(), outputFormat: PullOffersTimeFormat.DDMMYYYY_HHmmss) ?? "")'",
            "TODAY_UTC": "'\(PullOffersTimeManager.toString(date: Date(), outputFormat: PullOffersTimeFormat.DDMMYYYY_HHmmss) ?? "")'",
            "TIMEZONE": Float(TimeZone.current.abbreviation()?.substring(3) ?? "") ?? 0,
            "GDM_UTC": calendar.component(.day, from: PullOffersTimeManager.getUTCDate()),
            "GDS_UTC": calendar.component(.weekday, from: PullOffersTimeManager.getUTCDate()) - 1,
            "GMA_UTC": calendar.component(.month, from: PullOffersTimeManager.getUTCDate()),
            "GMY_UTC": calendar.component(.year, from: PullOffersTimeManager.getUTCDate()),
            "REC_USER": hasPersistedUser,
            "REC_PSE": clientSegment,
            "REC_PSC": commercialSegment
        ])
        return UseCaseResponse.ok()
    }
    
    // MARK: - Private methods
    
    private func getEscapedString(string: String) -> String {
        return "\"\(string)\""
    }
}
