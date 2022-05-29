import UIKit
import UI
import CoreFoundationLib

@objc protocol TextFieldFormatter: UITextFieldDelegate {
    @objc optional func maximumIntegerDigits(value: Int)
    @objc optional func maximumFractionDigits(value: Int)
}

protocol TextFieldFormatterProtocol {
    var delegate: ChangeTextFieldDelegate? { get set }
}

class FormattedTextField: KeyboardTextField {
    
    lazy var parser: TextFieldFormatter & TextFieldFormatterProtocol = {
        return AmountTextFieldFormatter(maximumIntegerDigits: maximumIntegerDigits, maximumFractionDigits: maximumFractionDigits)
    }()
    
    var customDelegate: ChangeTextFieldDelegate? {
        get {
            return parser.delegate
        }
        set {
            parser.delegate = newValue
        }
    }
    var maximumIntegerDigits: Int = 12 {
        didSet {
            parser.maximumIntegerDigits?(value: maximumIntegerDigits)
        }
    }
    
    var maximumFractionDigits: Int = 5 {
        didSet {
            parser.maximumFractionDigits?(value: maximumFractionDigits)
        }
    }
    
    var textFormatMode: FormatMode = .defaultCurrency(12, 2) {
        didSet {
            setupFormat(format: textFormatMode)
        }
    }
    
    var rightImageIdentifier: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 11.0, *) {
            smartInsertDeleteType = .no
        }
        delegate = parser
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 15
        return rect
    }

    private func setupFormat(format: FormatMode) {
        parser = format.formatter
        delegate = parser
        if let image = format.image {
            rightViewMode = .always
            let image = UIImageView(image: image)
            image.frame = CGRect(x: 0.0, y: 0.0, width: image.frame.width, height: image.frame.width)
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = false
            if let rightImageIdentifier = rightImageIdentifier {
                image.isAccessibilityElement = true
                image.accessibilityIdentifier = rightImageIdentifier
                image.image?.accessibilityIdentifier = rightImageIdentifier + "Image"
            }
            rightView = image
        } else if let text = format.text {
            rightViewMode = .always
            let label = UILabel()
            label.text = text
            label.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 16), textAlignment: .center))
            label.frame = CGRect(x: 0.0, y: 0.0, width: 60, height: 19)
            rightView = label
        }
        switch format {
        case let .currency(maxInteger, maxFraction, _):
            maximumIntegerDigits = maxInteger
            maximumFractionDigits = maxFraction
        case let .numeric(maxInteger, maxFraction):
            maximumIntegerDigits = maxInteger
            maximumFractionDigits = maxFraction
        case let .numericInteger(maxInteger):
            maximumIntegerDigits = maxInteger
        case .percentage:
            break
        }
    }
    
    func formatWith(string: String?) {
        guard let string = string else {
            text = nil
            return
        }
        _ = parser.textField?(self, shouldChangeCharactersIn: NSRange(location: 0, length: self.text?.count ?? 0), replacementString: string)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if case .percentage = textFormatMode {
            
            return super.canPerformAction(action, withSender: sender)
        }
        if action == #selector(paste(_:)) {
            
            return text?.isEmpty ?? true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    func setRightImageIdentifier (identifier: String?) {
        self.rightImageIdentifier = identifier
    }
    
}

extension FormattedTextField {
    
    enum FormatMode {
        case currency(Int, Int, String)
        case numeric(Int, Int)
        case numericInteger(Int)
        case percentage
        
        static func defaultCurrency(_ maxInteger: Int, _ maxFraction: Int) -> FormatMode {
            return .currency(maxInteger, maxFraction, CoreCurrencyDefault.default.rawValue)
        }
        
        var image: UIImage? {
            switch self {
            case .currency(_, _, let code):
                return code == "EUR" || code == "€" ? Assets.image(named: "incEuro") : nil
            case .numeric:
                return nil
            case .numericInteger:
                return nil
            case .percentage:
                return Assets.image(named: "incPercentage")
            }
        }
        
        var text: String? {
            switch self {
            case .currency(_, _, let currencyCode):
                return currencyCode
            case .numeric:
                return nil
            case .numericInteger:
                return nil
            case .percentage:
                return nil
            }
        }
        
        var formatter: TextFieldFormatter & TextFieldFormatterProtocol {
            switch self {
            case let .currency(maxInteger, maxFraction, _):
                return AmountTextFieldFormatter(maximumIntegerDigits: maxInteger, maximumFractionDigits: maxFraction)
            case let .numeric(maxInteger, maxFraction):
                return AmountTextFieldFormatter(maximumIntegerDigits: maxInteger, maximumFractionDigits: maxFraction)
            case let .numericInteger(maxInteger):
                return NumericTextFieldFormatter(maximumIntegerDigits: maxInteger)
            case .percentage:
                return PercentageTextFieldFormatter()
            }
        }
    }
    
}
