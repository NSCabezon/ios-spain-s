import UIKit

protocol TransactionDetailActionType {
    var title: LocalizedStylableText { get }
    var action: (() -> Void)? { get }
    var textColor: UIColor { get }
}

struct TransactionDetailAction: TransactionDetailActionType {
    let title: LocalizedStylableText
    let action: (() -> Void)?
    var isRedText: Bool
    var textColor: UIColor {
        return isRedText ? .sanRed : .sanGreyDark
    }
    
    init(title: LocalizedStylableText, isRedText: Bool = false, action: (() -> Void)?) {
        self.title = title
        self.isRedText = isRedText
        self.action = action
    }
}

class ButtonStackView: UIView {
    
    private var rows = [RowView]()
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        containerStackView.embedInto(container: self, insets: UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10))
    }
    
    // MARK: Public
    
    func setOptions(_ options: [TransactionDetailActionType]) {
        for v in containerStackView.arrangedSubviews {
            containerStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        let isTwoElementsPerRow = options.count % 2 == 0
        let elementsPerRow = isTwoElementsPerRow ? 2 : 3
        let groupedOptions = stride(from: 0, to: options.count, by: elementsPerRow).map { Array(options[$0 ..< min($0 + elementsPerRow, options.count)]) }
        for rowOptions in groupedOptions {
            addRowWith(rowOptions)
        }
    }
    
    // MARK: Private
    
    private func addRowWith(_ options: [TransactionDetailActionType]) {
        let rowView = RowView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        rowView.axis = .horizontal
        rowView.distribution = .fillEqually
        rowView.spacing = 10
        rows.append(rowView)
        containerStackView.addArrangedSubview(rowView)
        rowView.addOptions(options)
    }
}
