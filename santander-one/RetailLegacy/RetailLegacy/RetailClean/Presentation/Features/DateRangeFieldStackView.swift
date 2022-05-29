import UIKit

extension DateFieldStackView: ViewCreatable {}

class DateRangeFieldStackView: StackItemView {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    lazy var dateFromView: DateFieldStackView? = {
        guard let v = DateFieldStackView.instantiateFromNib() else {
            return nil
        }
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var dateToView: DateFieldStackView? = {
        guard let v = DateFieldStackView.instantiateFromNib() else {
            return nil
        }
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        setupViews()
    }
    
    func setupViews() {
        if let dateFromView = dateFromView {
            stackView.addArrangedSubview(dateFromView)
        }
        if let dateToView = dateToView {
            stackView.addArrangedSubview(dateToView)
        }
        leftLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoBoldItalic(size: 14)))
        rightLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoBoldItalic(size: 14)))
    }
    
    func setLeftTitle(_ title: LocalizedStylableText) {
        leftLabel.set(localizedStylableText: title)
    }
    
    func setRightTitle(_ title: LocalizedStylableText) {
        rightLabel.set(localizedStylableText: title)
    }

    func setVisibility(_ isVisible: Bool) {
        isHidden = !isVisible
    }
    
}
