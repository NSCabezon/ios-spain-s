import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Foundation

class LoadContactsUseCase: UseCase<Void, LoadContactsUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadContactsUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: CoreFoundationLib.GlobalPositionRepresentable.self)
        let appRepository: AppRepositoryProtocol = dependenciesResolver.resolve()
        let userPrefEntity = appRepository.getUserPreferences(userId: globalPosition.userId ?? "")
        let favoriteContacts = userPrefEntity.pgUserPrefDTO.favoriteContacts
        let bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let bsanTransfersManager = bsanManagersProvider.getBsanTransfersManager()
        let bsanResponse = try bsanTransfersManager.loadAllUsualTransfers()
        if bsanResponse.isSuccess(), let favorites = try bsanResponse.getResponseData() {
            return .ok(LoadContactsUseCaseOkOutput(contacts: favorites, favoriteContacts: favoriteContacts))
        }
        return .error(StringErrorOutput(try bsanResponse.getErrorMessage()))
    }
}

struct LoadContactsUseCaseOkOutput {
    let contacts: [PayeeRepresentable]
    let favoriteContacts: [String]?
}
