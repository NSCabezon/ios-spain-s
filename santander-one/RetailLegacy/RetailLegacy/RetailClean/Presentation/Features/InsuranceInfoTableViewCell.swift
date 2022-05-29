import UIKit

class InsuranceInfoTableViewCell: BaseViewCell {
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var isFirst: Bool = false {
        didSet {
            showSeparator()
        }
    }
    
    var isLast: Bool = false {
        didSet {
            bottomSpace()
        }
    }
    
    var infoTitle: String? {
        get {
            return titleLabel.text
        }
        
        set {
            titleLabel.text = newValue
        }
    }
    
    var info: String? {
        get {
            return infoLabel.text
        }
        
        set {
            infoLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 18.0)))
        infoLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoItalic(size: 16.0)))
        separator.backgroundColor = .lisboaGray
        backgroundColor = .white
    }
    
    func showSeparator() {
        separator.isHidden = isFirst
    }
    
    func bottomSpace() {
        if isLast {
            bottomConstraint.constant = 70
        } else {
            bottomConstraint.constant = 13
        }
    }

}
