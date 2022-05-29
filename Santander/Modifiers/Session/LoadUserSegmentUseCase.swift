import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class LoadUserSegmentUseCase: UseCase<Void, LoadUserSegmentUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    private let magicUsers = ["13007802", "13655152", "29091469", "38676373", "15869"]
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadUserSegmentUseCaseOkOutput, StringErrorOutput> {
        let userSegmentResponse = try managersProvider.getBsanUserSegmentManager().loadUserSegment()
        if userSegmentResponse.isSuccess(), let userSegment = try userSegmentResponse.getResponseData() {
            try storeIfAvailablePersistedUser(userSegmentDTO: userSegment)
            try storeSelectUser(userSegmentDTO: userSegment)
            try storeSmartUser(userSegmentDTO: userSegment)
            return UseCaseResponse.ok(LoadUserSegmentUseCaseOkOutput(isSelect: try appRepository.getCommercialSegment().getResponseData()?.isSelect ?? false))
        }
        return UseCaseResponse.error(StringErrorOutput(try userSegmentResponse.getErrorMessage()))
    }
}

private extension LoadUserSegmentUseCase {
    
    func getCommercialSegment(bpdSegmentCode: String?, commercialSegmentCode: String?) throws -> CommercialSegmentEntity? {
        let isPb = try checkRepositoryResponse(managersProvider.getBsanSessionManager().isPB()) ?? false
        
        let matcher = SegmentedUserMatcher(isPB: isPb, repository: segmentedUserRepository)
        guard let commercialSegmentDto = matcher.retrieveUserSegment(bdpType: bpdSegmentCode, comCode: commercialSegmentCode) else {
            return nil
        }
        
        return CommercialSegmentEntity(dto: commercialSegmentDto)
    }
    
    func storeSelectUser(userSegmentDTO: UserSegmentDTO) throws {
        guard let commercialSegment = try getCommercialSegment(bpdSegmentCode: userSegmentDTO.bdpSegment?.clientSegment?.segment, commercialSegmentCode: userSegmentDTO.commercialSegment?.clientSegment?.segment) else { return }
        
        _ = appRepository.setCommercialSegment(segment: commercialSegment)
        
        let isSelect = commercialSegment.isSelect
        managersProvider.getBsanUserSegmentManager().saveIsSelectUSer(isSelect)
    }
    
    func storeSmartUser(userSegmentDTO: UserSegmentDTO) throws {
        let isPB = try checkRepositoryResponse(managersProvider.getBsanSessionManager().isPB()) ?? false
        let globalPosition = try checkRepositoryResponse(managersProvider.getBsanPGManager().getGlobalPosition())
        let isMagicUser = magicUsers.contains(globalPosition?.userDataDTO?.clientPersonCode ?? "")
        let isSelect = try appRepository.getCommercialSegment().getResponseData()?.isSelect ?? false
        let isSmartUser = !isPB && !isSelect &&
            (isMagicUser || userSegmentDTO.colectivo123Smart == true || userSegmentDTO.colectivo123SmartFree == true)
        managersProvider.getBsanUserSegmentManager().saveIsSmartUser(isSmartUser)
        if try persistedUserExists(), let persistedUserDTO = try appRepository.getPersistedUser().getResponseData() {
            RetailLogger.i(logTag, "Store data in persisted user")
            persistedUserDTO.isSmart = isSmartUser
            _ = appRepository.setPersistedUserDTO(persistedUserDTO: persistedUserDTO)
        } else {
            RetailLogger.i(logTag, "User is not persisted")
        }
    }
    
    func storeIfAvailablePersistedUser(userSegmentDTO: UserSegmentDTO) throws {
        if try persistedUserExists(), let persistedUserDTO = try appRepository.getPersistedUser().getResponseData() {
            RetailLogger.i(logTag, "Store data in persisted user")
            persistedUserDTO.bdpCode = userSegmentDTO.bdpSegment?.clientSegment?.segment
            persistedUserDTO.comCode = userSegmentDTO.commercialSegment?.clientSegment?.segment
            _ = appRepository.setPersistedUserDTO(persistedUserDTO: persistedUserDTO)
        } else {
            RetailLogger.i(logTag, "User is not persisted")
        }
    }
    
    func persistedUserExists() throws -> Bool {
        return try appRepository.getPersistedUser().isSuccess() && appRepository.getPersistedUser().getResponseData() != nil
    }
}

extension LoadUserSegmentUseCase: RepositoriesResolvable {}

struct LoadUserSegmentUseCaseOkOutput {
    let isSelect: Bool
}
