import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class SpainLoadGlobalPositionUseCase: UseCase<Void, LoadGlobalPositionUseCaseOKOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    let appRepository: AppRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadGlobalPositionUseCaseOKOutput, StringErrorOutput> {
        let isPb = try isPersistedUserPb()
        
        let mBSANResponse: BSANResponse<GlobalPositionDTO> = try managersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: isPb)
        if mBSANResponse.isSuccess(), let globalPositionDTO = try mBSANResponse.getResponseData() {
            // usuario mixto
            if let isUserPrefPb = try appRepository.getPersistedUser().getResponseData()?.isPb {
                if isUserPrefPb && !isPb {
                    RetailLogger.i(logTag, "Mixed User in PB mode detected!")
                    return try loadGlobalPosition(isPb: true)
                    
                } else if !isUserPrefPb && isPb {
                    RetailLogger.i(logTag, "Mixed User in Retail mode detected!")
                    return try loadGlobalPosition(isPb: false)
                }
            }
            _ = appRepository.setTempName(name: formatName(globalPositionDTO))
            let sessionRepository = self.dependenciesResolver.resolve(forOptionalType: UserSessionRepository.self)
            sessionRepository?.saveUserData(globalPositionDTO.userDataDTO)
            sessionRepository?.saveIsPB(isPb)
            return .ok(LoadGlobalPositionUseCaseOKOutput(globalPosition: GlobalPositionEntity(isPb: isPb, dto: globalPositionDTO)))
            
        } else if try isWrongUserTypeError(mBSANResponse) {
            RetailLogger.i(logTag, "PB User detected")
            return try loadGlobalPosition(isPb: true)
        }
        
        return UseCaseResponse.error(StringErrorOutput(try mBSANResponse.getErrorMessage()))
    }
    
    private func formatName(_ globalPositionDTO: GlobalPositionDTO) -> String {
        if let clientNameWithoutSurname = globalPositionDTO.clientNameWithoutSurname, !clientNameWithoutSurname.isEmpty {
            return "\(clientNameWithoutSurname) \(globalPositionDTO.clientFirstSurname?.surname ?? "") \(globalPositionDTO.clientSecondSurname?.surname ?? "")"
        }
        
        return globalPositionDTO.clientName ?? ""
    }
    
    private func isWrongUserTypeError(_ bsanResponse: BSANResponse<GlobalPositionDTO>) throws -> Bool {
        return try isPbUserError(bsanResponse) || isRetailUserError(bsanResponse)
    }
    
    private func isPbUserError(_ bsanResponse: BSANResponse<GlobalPositionDTO>) throws -> Bool {
        return try bsanResponse.getErrorCode().uppercased() == "1"
        && bsanResponse.getErrorMessage()?.uppercased().contains("SANTANDER PRIVATE BANKING") ?? false
    }
    
    private func isRetailUserError(_ bsanResponse: BSANResponse<GlobalPositionDTO>) throws -> Bool {
        return try bsanResponse.getErrorCode().uppercased() == "1"
        && bsanResponse.getErrorMessage()?.uppercased().contains("SANTANDER BANCA PARTICULARES") ?? false
    }
    
    private func isPersistedUserPb() throws -> Bool {
        if let persistedUser = try appRepository.getPersistedUser().getResponseData(), persistedUser.isPb {
            RetailLogger.d(logTag, "PB User")
            return true
        }
        RetailLogger.d(logTag, "Retail User")
        return false
    }
    
    private func loadGlobalPosition(isPb: Bool) throws -> UseCaseResponse<LoadGlobalPositionUseCaseOKOutput, StringErrorOutput> {
        let bsanResponse = try managersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: isPb)
        if bsanResponse.isSuccess(), let globalPositionDTO = try bsanResponse.getResponseData() {
            let globalPosition = GlobalPositionEntity(isPb: isPb, dto: globalPositionDTO)
            _ = appRepository.setTempName(name: formatName(globalPositionDTO))
            _ = appRepository.setUserPrefPb(isPB: isPb, userId: globalPosition.userId ?? "")
            let sessionRepository = self.dependenciesResolver.resolve(forOptionalType: UserSessionRepository.self)
            sessionRepository?.saveUserData(globalPositionDTO.userDataDTO)
            sessionRepository?.saveIsPB(isPb)
            return UseCaseResponse.ok(LoadGlobalPositionUseCaseOKOutput(globalPosition: globalPosition))
        } else if try isWrongUserTypeError(bsanResponse) {
            RetailLogger.d(logTag, "Wrong type of user")
            return try loadGlobalPosition(isPb: !isPb)
        }
        return .error(StringErrorOutput(try bsanResponse.getErrorMessage()))
    }
}

extension SpainLoadGlobalPositionUseCase: LoadGlobalPositionUseCase {}
extension SpainLoadGlobalPositionUseCase: RepositoriesResolvable {}
