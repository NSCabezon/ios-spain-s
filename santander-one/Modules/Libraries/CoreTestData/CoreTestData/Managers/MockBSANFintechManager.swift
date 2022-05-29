import SANLegacyLibrary

struct MockBSANFintechManager: BSANFintechManager {
    func confirmWithAccessKey(authenticationParams: FintechUserAuthenticationInputParams, userInfo: FintechUserInfoAccessKeyParams) throws -> BSANResponse<FintechAccessConfimationResponseDTO> {
        fatalError()
    }
    
    func confirmWithFootprint(authenticationParams: FintechUserAuthenticationInputParams, userInfo: FintechUserInfoFootprintParams) throws -> BSANResponse<FintechAccessConfimationResponseDTO> {
        fatalError()
    }
}
