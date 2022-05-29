//

import UIKit
import UI

protocol CheckTableViewCellDelegate: class {
    func checkTableViewCellDidSelect()
}

protocol CheckTableViewCellProtocol {
    func hideLine()
    func showLine()
}

class CheckTableViewCell: BaseViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var line: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var stackTopConstraint: NSLayoutConstraint!

    // MARK: - Public attributes
    
    weak var delegate: CheckTableViewCellDelegate?
    
    // MARK: - Public methods
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
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

        selectionStyle = .none
        contentView.backgroundColor = .clear
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
        delegate?.checkTableViewCellDidSelect()
    }
}

extension CheckTableViewCell: CheckTableViewCellProtocol {

    func hideLine() {
        line.isHidden = true
    }

    func showLine() {
        line.isHidden = false
    }

}
