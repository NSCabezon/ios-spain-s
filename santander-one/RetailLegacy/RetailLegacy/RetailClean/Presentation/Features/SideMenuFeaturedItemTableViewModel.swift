import CoreFoundationLib
import CoreDomain

final class SideMenuFeaturedItemTableViewModel: TableModelViewItem<MenuFeaturedItemTableViewCell> {
    
    // MARK: - Public
    var imageKey: String?
    var title: LocalizedStylableText
    var extraMessage: String
    var newMessage: LocalizedStylableText?
    var imageURL: String?
    var showArrow: Bool
    var isHighlighted: Bool
    var type: PrivateMenuOptions?
    var isFeatured: Bool
    var isInnerTitle: Bool
    private weak var view: MenuFeaturedItemTableViewCell?
    
    // MARK: - Events
    var didSelect: (() -> Void)?
    
    init(title: LocalizedStylableText,
         imageKey: String? = nil,
         imageURL: String? = nil,
         extraMessage: String,
         newMessage: LocalizedStylableText?,
         viewModelPrivateComponent: PresentationComponent,
         showArrow: Bool = false,
         isHighlighted: Bool,
         type: PrivateMenuOptions? = nil,
         isFeatured: Bool,
         isInnerTitle: Bool = false) {
        self.title = title
        self.imageKey = imageKey
        self.imageURL = imageURL
        self.extraMessage = extraMessage
        self.newMessage = newMessage
        self.showArrow = showArrow
        self.isHighlighted = isHighlighted
        self.type = type
        self.isFeatured = isFeatured
        self.isInnerTitle = isInnerTitle
        super.init(dependencies: viewModelPrivateComponent)
    }

    override func bind(viewCell: MenuFeaturedItemTableViewCell) {
        viewCell.titleText = title
        viewCell.descriptionText = extraMessage
        viewCell.newText = newMessage
        viewCell.isFeaturedCell = isFeatured
        viewCell.isHighlightedCell = isHighlighted
        if let imageKey = imageKey {
            viewCell.setImage(named: imageKey)
        } else if let imageURL = imageURL {
            dependencies.imageLoader.load(relativeUrl: imageURL,
                                          imageView: viewCell.iconImageView,
                                          placeholderIfDoesntExist: nil)
        } else {
            viewCell.hideImage()
        }
        self.view = viewCell
        viewCell.setFeaturedCell(isFeatured: isFeatured)
        viewCell.setHighlightedCell(isHighlight: isHighlighted)
        viewCell.setSubTitle(isInnerTitle)
        viewCell.showSubmenuArrow(showArrow: showArrow)
    }
    
    func animationCell() {
        self.view?.animateViewCell()
    }
    
    func resetAnimationCell() {
        self.view?.resetAnimationCell()
    }
}

extension SideMenuFeaturedItemTableViewModel: Executable {
    func execute() {
        didSelect?()
    }
}
