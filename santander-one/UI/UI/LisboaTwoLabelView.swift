import UIKit
import CoreFoundationLib

public final class LisboaTwoLabelView: UIView {
    private let titleLeftLocalizedText: LocalizedStylableText
    private let titleRightLocalizedText: LocalizedStylableText
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 4
        stack.alignment = .top
        return stack
    }()
    
    public init(leftLocalizedText: LocalizedStylableText, rightLocalizedText: LocalizedStylableText) {
        self.titleLeftLocalizedText = leftLocalizedText
        self.titleRightLocalizedText = rightLocalizedText
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.backgroundColor = .clear
        let labelLeft = UILabel()
        labelLeft.textColor = .mediumSanGray
        labelLeft.configureText(withLocalizedString: titleLeftLocalizedText, andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 11.0), alignment: .left))
        labelLeft.numberOfLines = 0
        labelLeft.translatesAutoresizingMaskIntoConstraints = false
        labelLeft.setContentHuggingPriority(.required, for: .horizontal)
        let labelRight = UILabel()
        labelRight.textColor = .mediumSanGray
        labelRight.configureText(withLocalizedString: titleRightLocalizedText, andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 11.0), alignment: .left))
        labelRight.numberOfLines = 0
        self.stackView.addArrangedSubview(labelLeft)
        self.stackView.addArrangedSubview(labelRight)
        self.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
