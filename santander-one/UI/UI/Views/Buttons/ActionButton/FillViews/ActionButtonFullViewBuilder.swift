import CoreFoundationLib

final class ActionButtonFullViewBuilder {
    static func build(for type: ActionButtonFillViewType, isDragDisabled: Bool = false) -> ActionButtonFillViewProtocol? {
        switch type {
        case .defaultButton(let model):
            return DefaultActionButton(viewModel: model, isDragDisabled: isDragDisabled)
        case .offer(let model):
            return OfferImageViewActionButton(viewModel: model)
        case .centeredImage(let model):
            return CenteredImageActionButton(viewModel: model)
        case .defaultWithBackground(let model):
            return DefaultActionButton(viewModel: model)
        case .none:
            return nil
        }
    }
}
