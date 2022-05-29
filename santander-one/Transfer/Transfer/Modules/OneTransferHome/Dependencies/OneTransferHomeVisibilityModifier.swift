public protocol OneTransferHomeVisibilityModifier {
    var shouldShowFavoritesCarousel: Bool { get }
    var shouldShowNewFavoriteOption: Bool { get }
    var shouldShowRecentAndScheduledCarousel: Bool { get }
    var shouldShowHelpFooter: Bool { get }
    var newTransferType: OneAdditionalFavoritesActionsViewModel.ViewType { get }
}

public struct DefaultOneTransferHomeVisibilityModifier: OneTransferHomeVisibilityModifier {
    public var shouldShowFavoritesCarousel: Bool {
        return true
    }
    
    public var shouldShowNewFavoriteOption: Bool {
        return true
    }
    
    public var shouldShowRecentAndScheduledCarousel: Bool {
        return true
    }
    
    public var shouldShowHelpFooter: Bool {
        return true
    }
    
    public var newTransferType: OneAdditionalFavoritesActionsViewModel.ViewType {
        return .newTransfer
    }
}
