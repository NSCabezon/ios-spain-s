//

import UIKit

class RadioButtonCell: BaseViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var viewGray: UIView!
    @IBOutlet private weak var viewRed: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    var isChecked: Bool = false
    var title: LocalizedStylableText? {
        didSet {
            guard let title = title else { return }
            titleLabel.set(localizedStylableText: title)
        }
    }
    
    // MARK: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        viewGray.layer.cornerRadius = viewGray.frame.size.width / 2
        viewGray.layer.borderColor = UIColor.lisboaGray.cgColor
        viewGray.layer.borderWidth = 1
        viewRed.clipsToBounds = true
        viewRed.layer.cornerRadius = viewRed.frame.size.width / 2
        viewRed.backgroundColor = .sanRed
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16)))
        updateMarked()
    }
    
    // MARK: - Public methods
    
    func updateMarked() {
        viewRed.isHidden = !isChecked
        layoutIfNeeded()
    }
}

extension RadioButtonCell: RadioComponentProtocol {
    
    var isMark: Bool {
        return isChecked
    }
    
    func setMarked(isMarked: Bool) {
        isChecked = isMarked
        updateMarked()
    }
}
