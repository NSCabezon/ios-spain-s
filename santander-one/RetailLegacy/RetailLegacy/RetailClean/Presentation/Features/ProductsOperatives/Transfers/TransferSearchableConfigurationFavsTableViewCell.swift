import UIKit
import CoreFoundationLib

typealias FilterableSortableAndTitleDescriptionRepresentable = StringFilterable & Sortable & TitleDescriptionRepresentable & Hashable

protocol TitleDescriptionRepresentable {
    var representableTitle: String { get }
    var representableDescription: String? { get }
}

protocol StringFilterable {
    func isIncludedFilteredBy(_ term: String) -> Bool
}

protocol Sortable {
    func sortedBy() -> String
}

protocol TransferSearchableConfigurationFavsTableViewCellDelegate: class {
    func favsDidSelectIndex(_ index: Int)
}

class TransferSearchableConfigurationFavsTableViewCell: BaseViewCell {
    
    // MARK: - Public attributes
    
    var firstItem: TitleDescriptionRepresentable? {
        didSet {
            firstButton.setTitleAndDescription(from: firstItem)
            self.firstButton.accessibilityIdentifier = AccessibilityTransferHome.searchFirstButton
        }
    }
    
    var secondItem: TitleDescriptionRepresentable? {
        didSet {
            secondButton.setTitleAndDescription(from: secondItem)
            self.secondButton.accessibilityIdentifier = AccessibilityTransferHome.searchSecondButton
        }
    }
    
    var thirdItem: TitleDescriptionRepresentable? {
        didSet {
            thirdButton.setTitleAndDescription(from: thirdItem)
            self.thirdButton.accessibilityIdentifier = AccessibilityTransferHome.searchThirdButton
        }
    }
    
    var fourthItem: TitleDescriptionRepresentable? {
        didSet {
            fourthButton.setTitleAndDescription(from: fourthItem)
            self.fourthButton.accessibilityIdentifier = AccessibilityTransferHome.searchFourthButton
        }
    }
    
    var fifthItem: TitleDescriptionRepresentable? {
        didSet {
            fifthButton.setTitleAndDescription(from: fifthItem)
            self.fifthButton.accessibilityIdentifier = AccessibilityTransferHome.searchFifthButton
        }
    }
    
    var selectedIndex: Int? {
        didSet {
            guard let selectedIndex = selectedIndex else { return }
            setSelectedButton(at: selectedIndex)
        }
    }
    
    weak var delegate: TransferSearchableConfigurationFavsTableViewCellDelegate?
    
    // MARK: - Private attributes
    
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var secondButton: UIButton!
    @IBOutlet private weak var thirdButton: UIButton!
    @IBOutlet private weak var fourthButton: UIButton!
    @IBOutlet private weak var fifthButton: UIButton!
    
    // MARK: - Public methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyButtonsStyle()
        separateButtonsTouch()
        guard let selectedIndex = selectedIndex else { return }
        setSelectedButton(at: selectedIndex)
    }
    
    // MARK: - Private methods
    
    private func applyButtonsStyle() {
        allButtons().forEach {
            $0.backgroundColor = .uiBackground
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            StylizerPGViewCells.applyAllCornersViewCellStyle(view: $0)
        }
    }
    
    private func allButtons() -> [UIButton] {
        return [
            firstButton,
            secondButton,
            thirdButton,
            fourthButton,
            fifthButton
        ]
    }
    
    private func separateButtonsTouch() {
        allButtons().forEach { button in
            button.isExclusiveTouch = true
        }
    }
    
    private func setSelectedButton(at index: Int) {
        let selectedButton: UIButton = {
            switch index {
            case 0: return firstButton
            case 1: return secondButton
            case 2: return thirdButton
            case 3: return fourthButton
            case 4: return fifthButton
            default: return firstButton
            }
        }()
        StylizerPGViewCells.restoreStyle(view: selectedButton)
        selectedButton.layer.borderColor = UIColor.sanRed.cgColor
        selectedButton.layer.borderWidth = 1.0
        selectedButton.layer.cornerRadius = 5.0
        selectedButton.backgroundColor = .uiWhite
        let mutableAttributedString = selectedButton.currentAttributedTitle as? NSMutableAttributedString
        mutableAttributedString?.addAttribute(.color(.sanRed))
        selectedButton.setAttributedTitle(mutableAttributedString, for: .normal)
    }
    
    @IBAction private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case firstButton: delegate?.favsDidSelectIndex(0)
        case secondButton: delegate?.favsDidSelectIndex(1)
        case thirdButton: delegate?.favsDidSelectIndex(2)
        case fourthButton: delegate?.favsDidSelectIndex(3)
        case fifthButton: delegate?.favsDidSelectIndex(4)
        default: break
        }
    }
}

private extension UIButton {
    
    func setTitleAndDescription(from titleDescriptionRepresentable: TitleDescriptionRepresentable?) {
        guard let titleDescriptionRepresentable = titleDescriptionRepresentable else { return }
        let title: String = {
            if let description = titleDescriptionRepresentable.representableDescription {
                return titleDescriptionRepresentable.representableTitle + " " + "(" + description + ")"
            }
            return titleDescriptionRepresentable.representableTitle
        }()
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.font(.latoSemibold(size: 14)))
        attributedString.addAttribute(.color(.sanGreyDark))
        if let description = titleDescriptionRepresentable.representableDescription {
            attributedString.addAttribute(.font(.latoLight(size: 14)), to: "(" + description + ")")
        }
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
