import SANLegacyLibrary

public class BSANTouchIdManagerImplementation: BSANBaseManager, BSANTouchIdManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func registerTouchId(footPrint: String, deviceName: String) throws -> BSANResponse<TouchIdRegisterDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = TouchIdRegisterRequest(
            BSANAssembleProvider.getTouchIdRegisterAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            TouchIdRegisterRequestParams(token: authCredentials.soapTokenCredential,
                                         footPrint: footPrint,
                                         deviceName: deviceName,
                                         version: bsanHeaderData.version,
                                         terminalId: bsanHeaderData.terminalID,
                                         language: bsanHeaderData.language,
                                         userDataDTO: userDataDTO))
        
        let response: TouchIdRegisterResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            return BSANOkResponse(meta, response.touchIdRegisterDTO)
        }
        return BSANErrorResponse(meta)
    }
}
