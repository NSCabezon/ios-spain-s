import UIKit
import UI

protocol CheckStackViewDelegate: class {
    func checkStackViewDidSelect()
}

protocol CheckStackViewProtocol {
    func hideLine()
    func showLine()
}

class CheckStackView: StackItemView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var line: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkButton: UIButton!
    
    // MARK: - Public attributes
    
    weak var delegate: CheckStackViewDelegate?
    lazy var setCheckValue: ((Bool) -> Void) = { [weak self] value in
        self?.setSelected(value)
    }
    
    // MARK: - Public methods
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
        titleLabel.accessibilityIdentifier =  "newSendOnePay_check_\(title)"
    }
    
    func setSelected(_ selected: Bool) {
        checkButton.isSelected = selected
        if selected {
            titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0)))
        } else {
            titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 16.0)))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        line.backgroundColor = .lisboaGray
        checkButton.backgroundColor = .uiWhite
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0)))
        checkButton.setImage(Assets.image(named: "checkOk"), for: .selected)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        checkButton.layer.cornerRadius = 5
        checkButton.layer.borderColor = UIColor.lisboaGray.cgColor
        checkButton.layer.borderWidth = 1
    }
    
    // MARK: - Private methods
    
    @objc private func checkButtonTapped() {
        setSelected(!checkButton.isSelected)
        delegate?.checkStackViewDidSelect()
    }
}

extension CheckStackView: CheckStackViewProtocol {
    func hideLine() {
        line.isHidden = true
    }
    
    func showLine() {
        line.isHidden = false
    }
}
