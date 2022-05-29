import CoreFoundationLib

final class MenuOfferTableViewModel: TableModelViewItem<MenuOfferTableViewCell> {
    private let title: LocalizedStylableText
    private let imageKey: String?
    // MARK: - Events
    private let didSelect: (() -> Void)?
    
    init(title: LocalizedStylableText,
         imageKey: String? = nil,
         didSelect: (() -> Void)?,
         viewModelPrivateComponent: PresentationComponent) {
        self.title = title
        self.imageKey = imageKey
        self.didSelect = didSelect
        super.init(dependencies: viewModelPrivateComponent)
    }
    
    override func bind(viewCell: MenuOfferTableViewCell) {
        viewCell.title = title
        if let key = imageKey {
            viewCell.setImage(key)
        } else {
            viewCell.hideImage()
        }
    }
}

extension MenuOfferTableViewModel: Executable {
    func execute() {
        didSelect?()
    }
}
