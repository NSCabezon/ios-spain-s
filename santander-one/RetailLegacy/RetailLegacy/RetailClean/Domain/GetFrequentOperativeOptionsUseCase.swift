import CoreFoundationLib
import Foundation
import SANLegacyLibrary

struct FrequentOperative {
    let directLink: DirectLinkTypeItem
    var isEnabled: Bool
}

class GetFrequentOperativeOptionsUseCase: UseCase<Void, GetFrequentOperativeOptionUseCaseOkOutput, GetFrequentOperativeOptionUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    private let provider: BSANManagersProvider
    private let topOperativesDefaultEnabled: Int = 4
    
    init(provider: BSANManagersProvider, appRepository: AppRepository) {
        self.provider = provider
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFrequentOperativeOptionUseCaseOkOutput, GetFrequentOperativeOptionUseCaseErrorOutput> {
        guard let userId = try getUserId() else {
            return UseCaseResponse.ok()
        }
        let userPreferences = appRepository.getUserPrefDTO(userId: userId)
        guard userPreferences.isSuccess() else {
            return UseCaseResponse.error(GetFrequentOperativeOptionUseCaseErrorOutput(try userPreferences.getErrorMessage()))
        }
        let result: [FrequentOperative]
        if let storedOperatives = try userPreferences.getResponseData()?.frequentOperativePrefDTO {
            let loadedOperatives: [FrequentOperative] = storedOperatives.compactMap {
                guard let directLink = createDirectLink($0.id) else { return nil }
                return FrequentOperative(directLink: directLink, isEnabled: $0.isEnabled)
            }
            result = loadedOperatives.isEmpty ? getDefaultOperatives() : loadedOperatives
        } else {
            result = getDefaultOperatives()
        }
        return UseCaseResponse.ok(GetFrequentOperativeOptionUseCaseOkOutput(frequentOperatives: result.sorted(by: { $0.isEnabled && !$1.isEnabled})))
    }
    
    private func getDefaultOperatives() -> [FrequentOperative] {
        let defaultOperatives = DirectLinkTypeItem.allCases
        let result = defaultOperatives.enumerated().map { (index, deeplink) in
            FrequentOperative(directLink: deeplink, isEnabled: index < topOperativesDefaultEnabled)
        }
        
        return result
    }
    
    private func getUserId() throws -> String? {
        guard let globalPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition()) else {
            return nil
        }
        let userId = GlobalPosition.createFrom(dto: globalPositionDTO).userId
        
        return userId
    }
    
    private func createDirectLink(_ identifier: String) -> DirectLinkTypeItem? {
        return DirectLinkTypeItem(rawValue: identifier)
    }
}

struct GetFrequentOperativeOptionUseCaseOkOutput {
    let frequentOperatives: [FrequentOperative]
}

class GetFrequentOperativeOptionUseCaseErrorOutput: StringErrorOutput {
}
