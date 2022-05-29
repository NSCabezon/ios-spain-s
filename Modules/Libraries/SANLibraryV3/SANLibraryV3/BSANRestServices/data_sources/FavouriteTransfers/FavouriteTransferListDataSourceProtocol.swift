import Foundation

protocol FavouriteTransferListDataSourceProtocol: RestDataSource {
    func loadFavouriteTransferList() throws -> BSANResponse<[PayeeDTO]>
}
