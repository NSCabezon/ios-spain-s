public protocol BSANFavouriteTransfersManager {
    func getLocalFavourites() throws -> BSANResponse<[PayeeDTO]>
    func getFavourites() throws -> BSANResponse<[PayeeDTO]>
}
