import SANLegacyLibrary

struct MockBSANFavouriteTransfersManager: BSANFavouriteTransfersManager {
    func getLocalFavourites() throws -> BSANResponse<[PayeeDTO]> {
        fatalError()
    }
    
    func getFavourites() throws -> BSANResponse<[PayeeDTO]> {
        fatalError()
    }
}
