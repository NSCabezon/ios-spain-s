import Foundation
import SANLegacyLibrary

public class BSANSociusManagerImplementation: BSANBaseManager, BSANSociusManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getSociusAccounts() throws -> BSANResponse<[SociusAccountDTO]> {
        return BSANOkResponse(try bsanDataProvider.get(\.sociusInfo).sociusAccountsList)
    }
    
    public func getSociusLiquidation() throws-> BSANResponse<SociusLiquidationDTO>  {
        return BSANOkResponse(try bsanDataProvider.get(\.sociusInfo).sociusLiquidationDTO)
    }
    
    public func loadSociusDetailAccountsAll() throws -> BSANResponse<SociusAccountDetailDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        
        let request = GetSociusDetailAccountsAllRequest(
            BSANAssembleProvider.getSociusAssemble(),
            try bsanDataProvider.getEnvironment().urlSocius,
            GetSociusDetailAccountsAllRequestParams.createParams(authCredentials.soapTokenCredential)
                .setUserDataDTO(userDataDTO)
        )
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            
            if let sociusAccountDetailDTO = response.sociusAccountDetailDTO {
                storeSociusAccounts(sociusAccountDetailDTO)
                bsanDataProvider.storeSociusTotalLiquidation(sociusAccountDetailDTO: sociusAccountDetailDTO)
            }
            
            return BSANOkResponse(meta, response.sociusAccountDetailDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    private func storeSociusAccounts(_ sociusAccountDetailDTO: SociusAccountDetailDTO) {
        var sociusAccountDTOList: [SociusAccountDTO] = []
        for sociusAccountDTO in sociusAccountDetailDTO.sociusAccountList {
            sociusAccountDTOList.append(sociusAccountDTO)
        }
        bsanDataProvider.storeSociusAccounts(sociusAccountDTOList: sociusAccountDTOList)
    }
    
}
