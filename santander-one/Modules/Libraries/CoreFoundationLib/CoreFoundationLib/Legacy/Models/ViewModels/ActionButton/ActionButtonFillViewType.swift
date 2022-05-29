public enum ActionButtonFillViewType: Equatable {
    case none
    case defaultButton(DefaultActionButtonViewModel)
    case offer(OfferImageViewActionButtonViewModel)
    case centeredImage(CenteredImageActionButtonViewModel)
    case defaultWithBackground(DefaultActionButtonWithBackgroundViewModel)
    
    public static func == (lhs: ActionButtonFillViewType, rhs: ActionButtonFillViewType) -> Bool {
        switch (lhs, rhs) {
        case (.defaultButton(let lhsModel), .defaultButton(let rhsModel)):
            return lhsModel == rhsModel
        case (.offer(let lhsModel), .offer(let rhsModel)):
            return lhsModel == rhsModel
        case (.centeredImage(let lhsModel), .centeredImage(let rhsModel)):
            return lhsModel == rhsModel
        case (.defaultWithBackground(let lhsModel), .defaultWithBackground(let rhsModel)):
            return lhsModel == rhsModel
        default:
            return false
        }
    }
}
