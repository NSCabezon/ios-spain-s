import SANServicesLibrary
import SANLegacyLibrary

public class BSANPGManagerImplementation: BSANBaseManager, BSANPGManager {
    
    var sanSoapServices: SanSoapServices
    let storage: Storage
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices, storage: Storage) {
        self.sanSoapServices = sanSoapServices
        self.storage = storage
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func loadGlobalPosition(onlyVisibleProducts: Bool, isPB: Bool) throws -> BSANResponse<GlobalPositionDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = bsanDataProvider.getBsanHeaderData(isPB)
        
        let request = GlobalPositionRequest(
            BSANAssembleProvider.getGlobalPositionAssemble(false ,isPB),
            try bsanDataProvider.getEnvironment().urlBase,
            GlobalPositionRequestParams.createParams(isPb: isPB)
                .setToken(authCredentials.soapTokenCredential)
                .setLanguage(bsanHeaderData.language)
                .setTerminalId(bsanHeaderData.terminalID)
                .setOnlyVisibleProducts(onlyVisibleProducts ? "S" : "N")
                .setVersion(bsanHeaderData.version))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK(), var globalPositionDTO = response.globalPositionDTO {
            BSANLogger.i(logTag, "Meta OK");
            globalPositionDTO.isPb = isPB
            bsanDataProvider.updateSessionData(globalPositionDTO, isPB)
            return BSANOkResponse(meta, globalPositionDTO)
        }
        return BSANErrorResponse(meta)
        
    }
    
    public func loadGlobalPositionV2(onlyVisibleProducts: Bool, isPB: Bool) throws -> BSANResponse<GlobalPositionDTO> {
        return try self.syncronizeRequest(by: "LoadGlobalPositionV2") {
            if let getNewGlobalPositionDTO = try? bsanDataProvider.getNewGlobalPositionDTO(), onlyVisibleProducts {
                return BSANOkResponse<GlobalPositionDTO>(getNewGlobalPositionDTO)
            }
            let authCredentials = try bsanDataProvider.getAuthCredentials()
            let bsanHeaderData = bsanDataProvider.getBsanHeaderData(isPB)
            
            let request = GlobalPositionRequest(
                BSANAssembleProvider.getGlobalPositionAssemble(true ,isPB),
                try bsanDataProvider.getEnvironment().urlBase,
                GlobalPositionRequestParams.createParams(isPb: isPB)
                    .setToken(authCredentials.soapTokenCredential)
                    .setLanguage(bsanHeaderData.language)
                    .setTerminalId(bsanHeaderData.terminalID)
                    .setOnlyVisibleProducts(onlyVisibleProducts ? "S" : "N")
                    .setVersion(bsanHeaderData.version))
            
            let response = try sanSoapServices.executeCall(request)
            
            let meta = try Meta.createMeta(request, response)
            
            if meta.isOK(), var globalPositionDTO = response.globalPositionDTO {
                BSANLogger.i(logTag, "Meta OK");
                if onlyVisibleProducts {
                    globalPositionDTO.isPb = isPB
                    bsanDataProvider.store(newGlobalPositionDTO: globalPositionDTO)
                    storage.store(globalPositionDTO, id: "GlobalPositionV2")
                }
                return BSANOkResponse(meta, globalPositionDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func getGlobalPosition() throws -> BSANResponse<GlobalPositionDTO> {
        return BSANOkResponse<GlobalPositionDTO>(try bsanDataProvider.get(\.globalPositionDTO))
    }
}
