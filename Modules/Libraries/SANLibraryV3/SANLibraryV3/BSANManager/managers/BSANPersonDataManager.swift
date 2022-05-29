import SANLegacyLibrary

public class BSANPersonDataManagerImplementation: BSANBaseManager, BSANPersonDataManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func loadBasicPersonData() throws -> BSANResponse<PersonBasicDataDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetPersonBasicDataRequest(BSANAssembleProvider.getBasicPersonDataAssemble(), try bsanDataProvider.getEnvironment().urlBase, GetPersonBasicDataRequestParams(token: authCredentials.soapTokenCredential, userDataDTO: userDataDTO, linkedCompany: bsanHeaderData.linkedCompany, basicDataIndicator: "S", addressIndicator: "S", phoneIndicator: "S"))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, response.personBasicDataDTO)
        }
        return BSANErrorResponse(meta)
        
    }
    
    public func loadPersonDataList(clientDTOs: [ClientDTO]) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetPersonDataListRequest(
            BSANAssembleProvider.getPersonDataAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            GetPersonDataListRequestParams.createParams(authCredentials.soapTokenCredential)
                .setUserDataDTO(userDataDTO)
                .setVersion(bsanHeaderData.version)
                .setTerminalId(bsanHeaderData.terminalID)
                .setLanguage(bsanHeaderData.language)
                .setClientDTOs(clientDTOs)
        )
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            if let personDataDTOs = response.personDataDTOs {
                try storePersonData(personDataDTOs: personDataDTOs)
            }
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    private func storePersonData(personDataDTOs: [PersonDataDTO]) throws {
        guard let accountDTOs = try bsanDataProvider.get(\.globalPositionDTO).accounts else { return }
        for personDataDTO in personDataDTOs {
            if let accountDTO = accountDTOs.first(where: { (account) -> Bool in
                return account.client == personDataDTO.client
            }) {
                bsanDataProvider.store(personDataDTO: personDataDTO, forAccount: accountDTO)
            }
        }
    }
    
    public func getPersonData(accountDTO: AccountDTO) throws -> BSANResponse<PersonDataDTO>  {
        guard let contractString = accountDTO.contract?.formattedValue else {
            throw BSANIllegalStateException("Malformed account contract")
        }
        let personDataDTO = try bsanDataProvider.get(\.accountInfo).personDataMap[contractString]
        return BSANOkResponse(personDataDTO)
    }
}
