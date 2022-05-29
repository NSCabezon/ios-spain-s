//
//  LoadGlobalPositionUseCaseProtocol.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 13/9/21.
//

import SANLegacyLibrary
import CoreDomain

public protocol LoadGlobalPositionUseCase: UseCase<Void, LoadGlobalPositionUseCaseOKOutput, StringErrorOutput> {}

public struct LoadGlobalPositionUseCaseOKOutput {
    
    public let globalPosition: CoreFoundationLib.GlobalPositionRepresentable
    
    public init(globalPosition: CoreFoundationLib.GlobalPositionRepresentable) {
        self.globalPosition = globalPosition
    }
}

public final class DefaultLoadGlobalPositionUseCase: UseCase<Void, LoadGlobalPositionUseCaseOKOutput, StringErrorOutput>, LoadGlobalPositionUseCase {
    
    let dependenciesResolver: DependenciesResolver
    let appRepository: AppRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = dependenciesResolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadGlobalPositionUseCaseOKOutput, StringErrorOutput> {
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let isPb = try appRepository.getPersistedUser().getResponseData()?.isPb ?? false
        let bsanResponse = try bsanManagersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: isPb)
        guard bsanResponse.isSuccess(), let dto = try bsanResponse.getResponseData() else {
            return .error(StringErrorOutput(try bsanResponse.getErrorMessage()))
        }
        let globalPosition = GlobalPositionEntity(
            isPb: isPb,
            dto: dto,
            cardsData: nil,
            prepaidCards: nil,
            cardBalances: nil,
            temporallyOffCards: nil,
            inactiveCards: nil,
            notManagedPortfolios: nil,
            managedPortfolios: nil,
            notManagedRVStockAccounts: nil,
            managedRVStockAccounts: nil
        )
        _ = appRepository.setTempName(name: formatName(dto))
        _ = appRepository.setUserPrefPb(isPB: isPb, userId: globalPosition.userId ?? "")
        let sessionRepository = self.dependenciesResolver.resolve(forOptionalType: UserSessionRepository.self)
        sessionRepository?.saveUserData(dto.userDataDTO)
        sessionRepository?.saveIsPB(isPb)
        return .ok(LoadGlobalPositionUseCaseOKOutput(globalPosition: globalPosition))
    }
}

private extension DefaultLoadGlobalPositionUseCase {
    func formatName(_ globalPositionDTO: GlobalPositionDTO) -> String {
        if let clientNameWithoutSurname = globalPositionDTO.clientNameWithoutSurname, !clientNameWithoutSurname.isEmpty {
            return "\(clientNameWithoutSurname) \(globalPositionDTO.clientFirstSurname?.surname ?? "") \(globalPositionDTO.clientSecondSurname?.surname ?? "")"
        }
        
        return globalPositionDTO.clientName ?? ""
    }
}
