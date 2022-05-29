import Foundation

public protocol BSANFintechManager {
    func confirmWithAccessKey(authenticationParams: FintechUserAuthenticationInputParams, userInfo: FintechUserInfoAccessKeyParams) throws -> BSANResponse<FintechAccessConfimationResponseDTO>
    func confirmWithFootprint(authenticationParams: FintechUserAuthenticationInputParams, userInfo: FintechUserInfoFootprintParams) throws -> BSANResponse<FintechAccessConfimationResponseDTO>
}
