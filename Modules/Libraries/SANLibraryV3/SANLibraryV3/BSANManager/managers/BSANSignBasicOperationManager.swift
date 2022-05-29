import SANLegacyLibrary
public final class BSANSignBasicOperationManagerImplementation: BSANBaseManager, BSANSignBasicOperationManager {

    private let sanRestServices: SanRestServices

    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func getSignaturePattern() throws -> BSANResponse<GetSignPatternDTO> {
        let userData = try self.bsanDataProvider.getUserData()
        let dataSource = SignBasicOperationDataSource(
            sanRestServices: self.sanRestServices,
            bsanDataProvider: self.bsanDataProvider,
            endpoint: .getSignPattern(cmc: userData.getCMC)
        )
        return try dataSource.execute()
    }

    public func startSignPattern(_ pattern: String, instaID: String) throws -> BSANResponse<SignBasicOperationDTO>  {
        let dataSource = SignBasicOperationDataSource(
            sanRestServices: self.sanRestServices,
            bsanDataProvider: self.bsanDataProvider,
            endpoint: .startSignPattern( patternId: pattern, instaId: instaID)
        )
        return try dataSource.execute()
    }

    public func validateSignPattern(_ input: SignValidationInputParams) throws -> BSANResponse<SignBasicOperationDTO> {
        let userData = try self.bsanDataProvider.getUserData()
        var inputModified = input
        inputModified.otpData?.contract = userData.getCMC
        let dataSource = SignBasicOperationDataSource(
            sanRestServices: self.sanRestServices,
            bsanDataProvider: self.bsanDataProvider,
            endpoint: .validateSignPattern(inputModified)
        )
        return try dataSource.execute()
    }
    
    public func getContractCmc() throws -> String {
        let userData = try self.bsanDataProvider.getUserData()
        return userData.getCMC
    }
}
