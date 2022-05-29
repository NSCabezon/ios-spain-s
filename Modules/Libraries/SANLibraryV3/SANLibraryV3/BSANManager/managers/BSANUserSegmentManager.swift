import SANLegacyLibrary

public class BSANUserSegmentManagerImplementation: BSANBaseManager, BSANUserSegmentManager {

    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func getUserSegment() throws -> BSANResponse<UserSegmentDTO> {
        let userSegmentDTO = try bsanDataProvider.get(\.userSegmentDTO)
        return BSANOkResponse(userSegmentDTO)
    }

    public func loadUserSegment() throws -> BSANResponse<UserSegmentDTO> {

        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = UserSegmentRequest(
                BSANAssembleProvider.getUserSegmentAssemble(),
                try bsanDataProvider.getEnvironment().urlBase, UserSegmentRequestParams(token: authCredentials.soapTokenCredential, version: bsanHeaderData.version, terminalId: bsanHeaderData.terminalID, language: bsanHeaderData.language, userDataDTO: userDataDTO))

        let response = try sanSoapServices.executeCall(request)

        let meta = try Meta.createMeta(request, response)
        if meta.isOK(), let userSegmentDTO = response.userSegmentDTO {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.storeUserSegment(userSegmentDTO: userSegmentDTO)
            return BSANOkResponse(meta, userSegmentDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func saveIsSelectUSer(_ isSelect: Bool) {
        bsanDataProvider.store(isSelect: isSelect)
    }
    
    public func isSelectUser() throws -> Bool {
        return try bsanDataProvider.isSelect()
    }

    public func saveIsSmartUser(_ isSmart: Bool) {
        bsanDataProvider.storeIsSmart(isSmart)
    }

    public func isSmartUser() throws -> Bool {
        return try bsanDataProvider.isSmart()
    }
}
