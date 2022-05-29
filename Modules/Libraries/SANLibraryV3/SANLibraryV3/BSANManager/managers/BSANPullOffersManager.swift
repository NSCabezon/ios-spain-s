import CoreFoundationLib
import SANLegacyLibrary

public class BSANPullOffersManagerImplementation: BSANBaseManager, BSANPullOffersManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getCampaigns() throws -> BSANResponse<[String]?> {
        let userCampaigns = try bsanDataProvider.get(\.userCampaigns)
        return BSANOkResponse(userCampaigns)
    }
    
    public func loadCampaigns() throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetBotesPullOffersRequest(
            BSANAssembleProvider.getPullOffersAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetBotesPullOffersRequestParams.createParams(authCredentials.soapTokenCredential)
                .setLanguage(bsanHeaderData.language)
                .setTerminalId(bsanHeaderData.terminalID)
                .setVersion(bsanHeaderData.version)
                .setUserDataDTO(userDataDTO))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response);
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            storeCampaigns(response.campaignDTOs)
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
}

private extension BSANPullOffersManagerImplementation {
    func storeCampaigns(_ campaignDTOs: [CampaignDTO]?) {
        if let campaignDTOs = campaignDTOs, !campaignDTOs.isEmpty {
            var userCampaigns: [String] = []
            for campaignDTO in campaignDTOs {
                if let idRule = campaignDTO.idRule {
                    userCampaigns.append(idRule)
                }
            }
            bsanDataProvider.storeUserCampaigns(userCampaigns: userCampaigns)
        }
    }
}
