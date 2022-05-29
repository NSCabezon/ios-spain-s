import Foundation
import SANLegacyLibrary

public class BSANFavouriteTransfersManagerImplementation: BSANBaseManager, BSANFavouriteTransfersManager {
    private let sanRestServices: SanRestServices
    
    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getLocalFavourites() throws -> BSANResponse<[PayeeDTO]> {
        return BSANOkResponse(try bsanDataProvider.get(\.transferInfo).microFavouriteTransferList)
    }
    
    public func getFavourites() throws -> BSANResponse<[PayeeDTO]> {
        let dataSource = FavouriteTransferListDataSource(sanRestServices: sanRestServices, bsanDataProvider: bsanDataProvider)
        let storedFavouriteTransfers: [PayeeDTO] = try bsanDataProvider.get(\.transferInfo).microFavouriteTransferList
        if storedFavouriteTransfers.count > 0 {
            return BSANOkResponse(storedFavouriteTransfers)
        }
        let response = try dataSource.loadFavouriteTransferList()
        if response.isSuccess(), let transfersDTO = try response.getResponseData() {
            bsanDataProvider.storeFavouriteTransfers(transfersDTO)
        } else {
            bsanDataProvider.removeFavouriteTransfer()
        }
        return response
    }
}
