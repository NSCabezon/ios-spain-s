import UIKit

class RadioButtonStackView: StackItemView {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var viewGray: UIView!
    @IBOutlet private weak var viewRed: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    var isChecked: Bool = false
    var title: LocalizedStylableText? {
        didSet {
            guard let title = title else { return }
            titleLabel.set(localizedStylableText: title)
        }
    }
    var valueAction: (() -> Void)?
    lazy var udpateAction: ((Bool) -> Void) = { [weak self] value in
        self?.setMarked(isMarked: value)
    }
    
    // MARK: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        viewGray.layer.cornerRadius = viewGray.frame.size.width / 2
        viewGray.layer.borderColor = UIColor.lisboaGray.cgColor
        viewGray.layer.borderWidth = 1
        viewRed.clipsToBounds = true
        viewRed.layer.cornerRadius = viewRed.frame.size.width / 2
        viewRed.backgroundColor = .sanRed
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16)))
        updateMarked()
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionButton(_:)))
        stackView.addGestureRecognizer(tap)
    }
    
    // MARK: - Public methods
    
    func updateMarked() {
        viewRed.isHidden = !isChecked
        layoutIfNeeded()
    }
    
    @IBAction func actionButton(_ sender: Any) {
        valueAction?()
    }
}

extension RadioButtonStackView: RadioComponentProtocol {
    
    var isMark: Bool {
        return isChecked
    }
    
    func setMarked(isMarked: Bool) {
        isChecked = isMarked
        updateMarked()
    }
}
