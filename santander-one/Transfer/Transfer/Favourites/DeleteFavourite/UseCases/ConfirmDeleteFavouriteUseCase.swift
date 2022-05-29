import CoreFoundationLib

public protocol ConfirmDeleteFavouriteUseCaseProtocol: UseCase<ConfirmDeleteFavouriteUseCaseInput, Void, GenericErrorSignatureErrorOutput> { }

public struct ConfirmDeleteFavouriteUseCaseInput {
    public let favoriteType: FavoriteType?
    public let signatureWithToken: SignatureWithTokenEntity?
    
    public init(favoriteType: FavoriteType? = nil, signatureWithToken: SignatureWithTokenEntity? = nil) {
        self.favoriteType = favoriteType
        self.signatureWithToken = signatureWithToken
    }
}
