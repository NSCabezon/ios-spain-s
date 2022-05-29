import SANLegacyLibrary

public class BSANManagersManagerImplementation: BSANBaseManager, BSANManagersManager {
    
    var sanSoapServices: SanSoapServices
    private let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices, sanRestServices: SanRestServices) {
        self.sanSoapServices = sanSoapServices
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getManagers() throws -> BSANResponse<YourManagersListDTO> {
        do{
            return BSANOkResponse(try bsanDataProvider.get(\.managersInfo).yourManagersListDTO)
        }
        catch{
            return BSANOkResponse(nil)
        }
    }
    
    public func loadManagers() throws -> BSANResponse<YourManagersListDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        
        let request = GetManagersRequest(
            BSANAssembleProvider.getSociusAssemble(),
            try bsanDataProvider.getEnvironment().urlSocius,
            GetManagersRequestParams(token: authCredentials.soapTokenCredential,
                                     userDataDTO: userDataDTO))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            
            bsanDataProvider.store(managers: response.yourManagersListDTO)
            return BSANOkResponse(response.yourManagersListDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func loadClick2Call() throws -> BSANResponse<Click2CallDTO> {
        return try loadClick2Call(nil)
    }
    
    public func loadClick2Call(_ reason: String?) throws -> BSANResponse<Click2CallDTO> {
        let dataSource = Click2CallDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        return try dataSource.getClick2Call(reason)
    }
}
