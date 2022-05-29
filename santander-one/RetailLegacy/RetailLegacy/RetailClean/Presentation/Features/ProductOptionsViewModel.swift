import UIKit

protocol ProductOptionViewModelDelegate: class {
    func productOption(didSelectIndex index: Int)
}

enum BackgroundColor {
    case gray
    case white
    
    public func getColor() -> UIColor {
        switch self {
        case .gray:
            return .sanGreyLight
        case .white:
            return .uiWhite
        }
    }
}

class ProductOptionsViewModel: TableModelViewItem<ProductOptionsTableViewCell> {
    
    weak var delegate: ProductOptionViewModelDelegate?
    var activeOptions: [ProductOption]?
    var backgroundColor: BackgroundColor?
    
    public var firstSeparatorCoachmarkId: CoachmarkIdentifier?
    public var secondSeparatorCoachmarkId: CoachmarkIdentifier?

    init(dependencies: PresentationComponent, backgroundColor: BackgroundColor? = nil) {
        self.backgroundColor = backgroundColor
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: ProductOptionsTableViewCell) {
        
        viewCell.delegate = self
        viewCell.cellColor = backgroundColor
        
        guard let options = activeOptions else { return }
        
        if let configOne = options[safe:0] {
            viewCell.configureFirstButton(with: configOne, firstSeparatorCoachmarkId: firstSeparatorCoachmarkId)
        } else {
            viewCell.productViewOne.isHidden = true
        }
        
        if let configTwo = options[safe:1] {
            viewCell.configureSecondButton(with: configTwo, secondSeparatorCoachmarkId: secondSeparatorCoachmarkId)
        } else {
            viewCell.productViewTwo.isHidden = true
        }
        
        if let configThree = options[safe:2] {
            viewCell.configureThirdButton(with: configThree)
        } else {
            viewCell.productViewThree.isHidden = true
        }
        
        if let configFour = options[safe:3] {
            viewCell.configureFourthButton(with: configFour)
        } else {
            viewCell.productViewFour.isHidden = true
        }
    }
}

extension ProductOptionsViewModel: ProductOptionsTableViewCellDelegate {
    func getIndex(_ index: Int) {
        delegate?.productOption(didSelectIndex: index)
    }
}
