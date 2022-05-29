import UIKit

class DispensationViewCell: BaseViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rightSpaceSeparatorConstraint: NSLayoutConstraint!
    @IBOutlet weak var separator: UIView!
    
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var amount: String? {
        get {
            return amountLabel.text
        }
        set {
            amountLabel.text = newValue
            amountLabel.scaleDecimals()
        }
    }
    
    var day: String? {
        get {
            return dayLabel.text
        }
        set {
            dayLabel.text = newValue
        }
    }
    
    var month: String? {
        get {
            return monthLabel.text
        }
        set {
            monthLabel.text = newValue
        }
    }
    
    var isFirstCell: Bool {
        get {
            return false
        }
        set {
            dayLabel.isHidden = !newValue
            monthLabel.isHidden = !newValue
            separator.isHidden = newValue
        }
    }
    
    var shouldDisplayDate: Bool {
        get {
            return dayLabel.isHidden
        }
        set {
            dayLabel.isHidden = !newValue
            monthLabel.isHidden = !newValue
            rightSpaceSeparatorConstraint.constant = newValue ? 12 : 54
        }
    }
    
    func dispensationStatus(statusText: LocalizedStylableText?, status: DispensationStatus) {
        statusView.isHidden = status == .undefined
        
        guard let text = statusText else {
            statusLabel.text = nil
            return
        }
        
        let color = UIColor.color(forDispositionStatus: status)
        statusView.layer.borderColor = color.cgColor
        statusLabel.textColor = color
        statusLabel.set(localizedStylableText: text)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dayLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 18.0)))
        monthLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 11.0)))
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 22.7)))
        amountLabel.scaleDecimals()
        statusLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 13.0), textAlignment: .center))
        statusView.layer.borderWidth = 1.0
        statusView.layer.borderColor = UIColor.sanRed.cgColor
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusView.layer.cornerRadius = 5
    }
}
