import UIKit

class GenericLandingPushDescriptionView: UIView {
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        containerStackView.embedInto(container: self, insets: UIEdgeInsets(top: 15, left: 10, bottom: -15, right: -10))
        backgroundColor = .clear
    }
    
    func addLeftTitle(_ title: LocalizedStylableText) {
        let label = createLabelWith(title)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santanderTextRegular(size: 12.0)
        label.textColor = .deepSanGrey
        containerStackView.addArrangedSubview(label)
    }
    
    func addLine(_ leftItem: String?, _ rightItem: String?) {
        let leftLabel = UILabel()
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.font = UIFont.santanderTextRegular(size: 16.0)
        leftLabel.textColor = .sanGreyDark
        leftLabel.text = leftItem
        
        let rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = UIFont.santanderTextRegular(size: 16.0)
        rightLabel.textColor = .sanGreyDark
        rightLabel.textAlignment = .right
        rightLabel.text = rightItem
        
        let line = createLine(leftItem: leftLabel, rightItem: rightLabel)
        containerStackView.addArrangedSubview(line)
    }
    
    func addItemAndColumnTitle(_ leftItem: String, _ rightItem: LocalizedStylableText) {
        let leftLabel = UILabel()
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.font = UIFont.santanderTextRegular(size: 16.0)
        leftLabel.textColor = .sanGreyDark
        leftLabel.text = leftItem
        
        let rightLabel = createLabelWith(rightItem)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = UIFont.santanderTextRegular(size: 12.0)
        rightLabel.textColor = .deepSanGrey
        rightLabel.textAlignment = .right
        
        let line = createLine(leftItem: leftLabel, rightItem: rightLabel)
        containerStackView.addArrangedSubview(line)
    }
    
    func addItemAndAmount(_ leftItem: String?, _ rightItem: String?) {
        let leftLabel = UILabel()
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.font = UIFont.santanderTextRegular(size: 14.0)
        leftLabel.textColor = .sanGreyDark
        leftLabel.text = leftItem
        
        let rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = UIFont.santanderTextRegular(size: 21.0)
        rightLabel.textColor = .sanGreyDark
        rightLabel.textAlignment = .right
        rightLabel.text = rightItem
        rightLabel.scaleDecimals()

        let line = createLine(leftItem: leftLabel, rightItem: rightLabel)
        containerStackView.addArrangedSubview(line)
    }
    
    func setupWith(_ accountInfo: [GenericLandingInfoLineType]) {
        for element in accountInfo {
            switch element {
            case let .title(value):
                addLeftTitle(value)
            case let .line(left, right):
                addLine(left, right)
            case let .itemAndColumnTitle(item, title):
                addItemAndColumnTitle(item, title)
            case let .itemAndAmount(item, amount):
                addItemAndAmount(item, amount)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func createLine(leftItem: UILabel?, rightItem: UILabel?) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        if let leftItem = leftItem {
            stackView.addArrangedSubview(leftItem)
        }
        if let rightItem = rightItem {
            stackView.addArrangedSubview(rightItem)
        }
        return stackView
    }
    
    private func createLabelWith(_ text: LocalizedStylableText) -> UILabel {
        let label = UILabel()
        label.set(localizedStylableText: text)
        
        return label
    }
}
