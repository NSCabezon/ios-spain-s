import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

protocol AppRepository: LanguageRepository, SessionRepository, AppRepositoryProtocol {
    
    // MARK: No session AppData //
    func isSessionEnabled() -> RepositoryResponse<Bool>

    // MARK: PersistedUser //
    func getPersistedUser() -> RepositoryResponse<PersistedUserDTO>
    func isPersistedUserPb() -> RepositoryResponse<Bool>
    func setSharedPersistedUser() -> RepositoryResponse<Void>
    
    // MARK: PersistedUserAvatar //
    func getPersistedUserAvatar(userId: String) -> RepositoryResponse<Data>
    func setPersistedUserAvatar(userId: String, image: Data) -> RepositoryResponse<Void>
    
    // MARK: Locale //
    func setLanguage(language: LanguageType) -> RepositoryResponse<Void>

    // MARK: OwnershipTypeDesc //
    func getTypeDescs() -> RepositoryResponse<[OwnershipTypeDesc]>
    func setTypeDescs(typeDescs: [OwnershipTypeDesc]?) -> RepositoryResponse<Void>

    // MARK: UserPref //
    func isUserPrefPb(userId: String) -> RepositoryResponse<Bool>
    func setUserPrefPb(isPB: Bool, userId: String) -> RepositoryResponse<Void>
    func getUserPrefDTO(userId: String) -> RepositoryResponse<UserPrefDTO>
    func setUserPrefDTO(userPrefDTO: UserPrefDTO) -> RepositoryResponse<Void>
    
    // MARK: First Login Messages //
    func setLoginMessages(checkings: [LoginMessagesState: Bool]) -> RepositoryResponse<Void>
    func getLoginMessagesCheckings() -> RepositoryResponse<[LoginMessagesState: Bool]>

    // MARK: Selected Product  //
    func getSelectedProduct() -> RepositoryResponse<SelectedProduct>
    func setSelectedProduct(selectedProduct: SelectedProduct) -> RepositoryResponse<Void>
    
    // MARK: Mixed User  //
    func isMixedUser() -> RepositoryResponse<Bool>
    func setMixedUsed(isMixedUser: Bool) -> RepositoryResponse<Void>
    
    
    func getTips() -> RepositoryResponse<[PullOffersConfigTip]?>

    // MARK: Environments //
    func getPublicFilesEnvironments() -> RepositoryResponse<[PublicFilesEnvironmentDTO]>
    func getInbentaEnvironments() -> RepositoryResponse<[InbentaEnvironmentDTO]>

    func getCurrentPublicFilesEnvironment() -> RepositoryResponse<PublicFilesEnvironmentDTO>
    func getCurrentInbentaEnvironment() -> RepositoryResponse<InbentaEnvironmentDTO>

    func setPublicEnvironment(publicFilesEnvironmentDTO: PublicFilesEnvironmentDTO) -> RepositoryResponse<Void>
    func setInbentaEnvironment(inbentaEnvironmentDTO: InbentaEnvironmentDTO) -> RepositoryResponse<Void>
    
    // MARK: Coachmarks //
    func isCoachmarkShown(coachmarkId: CoachmarkIdentifier, userId: String) -> RepositoryResponse<Bool>
    func setCoachmarkShown(coachmarkId: [CoachmarkIdentifier], userId: String) -> RepositoryResponse<Void>
}
