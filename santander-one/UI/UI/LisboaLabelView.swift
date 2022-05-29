import Foundation

public final class LisboaLabelView: UIView {
    private let text: String
    
    public init(text: String,
                textAlignment: NSTextAlignment = .center,
                font: UIFont = .santander(family: .text, type: .regular, size: 12.0),
                topMargin: CGFloat = 0.0,
                bottomMargin: CGFloat = 6.0,
                leftMargin: CGFloat = 8.0,
                rightMargin: CGFloat = 8.0,
                identifier: String? = nil
    ) {
        self.text = text
        super.init(frame: .zero)
        self.setup(textAlignment: textAlignment,
                   font: font,
                   topMargin: topMargin,
                   bottomMargin: bottomMargin,
                   leftMargin: leftMargin,
                   rightMargin: rightMargin,
                   identifier: identifier
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LisboaLabelView {
    func setup(textAlignment: NSTextAlignment,
               font: UIFont,
               topMargin: CGFloat,
               bottomMargin: CGFloat,
               leftMargin: CGFloat,
               rightMargin: CGFloat,
               identifier: String?
    ) {
        self.backgroundColor = .clear
        let label = UILabel()
        label.font = font
        label.textColor = .grafite
        label.textAlignment = textAlignment
        label.text = self.text
        label.numberOfLines = 0
        self.addSubview(label)
        label.fullFit(topMargin: topMargin, bottomMargin: bottomMargin, leftMargin: leftMargin, rightMargin: rightMargin)
        label.accessibilityIdentifier = identifier

    }
}
