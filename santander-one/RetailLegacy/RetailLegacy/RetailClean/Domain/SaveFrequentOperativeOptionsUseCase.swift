import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class SaveFrequentOperativeOptionsUseCase: UseCase<SaveFrequentOperativeOptionsUseCaseInput, Void, SaveFrequentOperativeOptionUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    private let provider: BSANManagersProvider
    private let topOperativesDefaultEnabled: Int = 4
    
    init(provider: BSANManagersProvider, appRepository: AppRepository) {
        self.provider = provider
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: SaveFrequentOperativeOptionsUseCaseInput) throws -> UseCaseResponse<Void, SaveFrequentOperativeOptionUseCaseErrorOutput> {
        
        guard let userId = try getUserId() else {
            return UseCaseResponse.ok()
        }
        let userPreferences = appRepository.getUserPrefDTO(userId: userId)
        guard userPreferences.isSuccess() else {
            return UseCaseResponse.error(SaveFrequentOperativeOptionUseCaseErrorOutput(try userPreferences.getErrorMessage()))
        }
        guard let currentUserPreferences = try userPreferences.getResponseData() else {
            return UseCaseResponse.ok()
        }
        var listToStore: [FrequentOperativePrefDTO] = requestValues.frequentOperatives.compactMap {
            guard let id = createDeeplinkIdentifier($0.directLink) else { return nil }
            return FrequentOperativePrefDTO(id: id, isEnabled: $0.isEnabled) }
        
        DirectLinkTypeItem.allCases.forEach { (defaultItem) in
            if !listToStore.contains(where: { $0.id == defaultItem.rawValue }) {
                listToStore.append(FrequentOperativePrefDTO(id: defaultItem.rawValue, isEnabled: false))
            }
        }
        
        currentUserPreferences.frequentOperativePrefDTO = listToStore
        let response = appRepository.setUserPrefDTO(userPrefDTO: currentUserPreferences)
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        
        return UseCaseResponse.error(SaveFrequentOperativeOptionUseCaseErrorOutput(try response.getErrorMessage()))
    }
    
    private func getUserId() throws -> String? {
        guard let globalPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition()) else {
            return nil
        }
        let userId = GlobalPosition.createFrom(dto: globalPositionDTO).userId
        
        return userId
    }
    
    private func createDeeplinkIdentifier(_ directLink: DirectLinkTypeItem) -> String? {
        return directLink.rawValue
    }
}

struct SaveFrequentOperativeOptionsUseCaseInput {
    let frequentOperatives: [FrequentOperative]
}

class SaveFrequentOperativeOptionUseCaseErrorOutput: StringErrorOutput {
}
