import UIKit

class OptionsStackView: UIStackView {
    
    let maxAmountPerLines = 4
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func addValues(_ values: [ValueOptionType]) {
        clearOptions()
        let rowOptions = stride(from: 0, to: values.count, by: maxAmountPerLines).map { Array(values[$0..<min($0 + maxAmountPerLines, values.count)])
        }
        for row in rowOptions {
            let emptyViewsCount = maxAmountPerLines - row.count
            let emptyViewArray = [ValueOptionType?](repeating: nil, count: emptyViewsCount)
            let options = AmountRowStack()
            options.heightAnchor.constraint(equalToConstant: 45).isActive = true
            stackView.addArrangedSubview(options)
            options.addAmounts(row + emptyViewArray)
        }
    }
    
    private func clearOptions() {
        for case let view as AmountRowStack in stackView.arrangedSubviews {
            view.clear()
            view.removeFromSuperview()
        }
    }
}
