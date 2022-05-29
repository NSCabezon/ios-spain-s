import UIKit

class OperativeStackViewTableViewCell: BaseViewCell {
    @IBOutlet weak var mainStack: UIStackView!
    private var buttons: [UIButton] = []
    private var lastSelected: Int?
    private let buttonsMaxRowElements = 4
    private let buttonsHeight: CGFloat = 50
    private let buttonsSeparatorVertical: CGFloat = 10
    private let buttonsWidth: CGFloat = UIScreen.main.isIphone4or5 ? 67.5 : 83
    private let buttonsInitialSepartion: CGFloat = 0
    var selectAmount: ((_ tag: Int) -> Void)?

    @IBAction func actionSelectAmount(_ sender: UIButton) {
        updateText(tag: sender.tag)
        selectAmount?(sender.tag)
    }
    
    var elements: [String]? {
        didSet {
            guard let newElements = elements else { return }
            if newElements != oldValue {
                drawButtons(elements: newElements)
            }
        }
    }
    
    func highlightButtons(tag: Int? = nil) {
        for button in buttons {
            if button.tag != tag {
                configureUnselectedButton(button: button)
            } else {
                configureSelectedButton(button: button)
            }
        }
    }
    
    private func updateText(tag: Int? = nil) {
        guard tag != lastSelected else {
            return
        }
        for button in buttons where button.tag == tag || button.tag == lastSelected {
            if button.tag != tag {
                configureUnselectedButton(button: button)
            } else {
                configureSelectedButton(button: button)
            }
        }
        lastSelected = tag
    }
    
    private func configureUnselectedButton(button: UIButton) {
        let style = ButtonStylist(textColor: .sanGreyDark, font: .latoRegular(size: 22))
        button.applyStyle(style)
        button.backgroundColor = .uiWhite
        button.drawRoundedAndShadowed()
    }
    
    private func configureSelectedButton(button: UIButton) {
        let style = ButtonStylist(textColor: .sanRed, font: .latoRegular(size: 22))
        button.applyStyle(style)
        button.backgroundColor = .uiWhite
        button.layer.shadowOpacity = 0
        button.layer.borderColor = UIColor.sanRed.cgColor
    }
    
    private func clearViewsOfMainStackView() {
        for stack in mainStack.arrangedSubviews {
            stack.removeFromSuperview()
        }
        mainStack.reloadInputViews()
    }
    
    func drawButtons(elements: [String]) {
        buttons.removeAll()
        clearViewsOfMainStackView()
        
        let maxRowElementsFloat = CGFloat(buttonsMaxRowElements)
        let separatorHorizontal = ( self.frame.size.width - buttonsWidth * maxRowElementsFloat ) / ( maxRowElementsFloat +  1 )
        let rows: Int
        let elementsAmount = elements.count
        let completeRows = elementsAmount / 4
        if elementsAmount % buttonsMaxRowElements == 0 {
            rows = completeRows
        } else {
            rows = 1 + completeRows
        }
        var y: CGFloat = buttonsInitialSepartion
        for i in 0..<rows {
            let columns = min(buttonsMaxRowElements, elementsAmount - i * buttonsMaxRowElements )
            let stackWidth = CGFloat(columns) * ( buttonsWidth + separatorHorizontal ) - separatorHorizontal
            let frame = CGRect(x: separatorHorizontal, y: y, width: stackWidth, height: buttonsHeight)
            let first = i * buttonsMaxRowElements
            let last  = first + columns
         
            addStackAmounts(texts: elements, frame: frame, tags: first..<last, y: y, separatorHorizontal: separatorHorizontal, isLast: i == rows - 1)
            y += buttonsSeparatorVertical + buttonsHeight
        }
    }
    
    private func addStackAmounts(texts: [String], frame: CGRect, tags: CountableRange<Int>, y: CGFloat, separatorHorizontal: CGFloat, isLast: Bool) {
        let stack = UIStackView(frame: frame)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = separatorHorizontal
        mainStack.addArrangedSubview(stack)
        stack.leftAnchor.constraint(equalTo: mainStack.leftAnchor, constant: separatorHorizontal).isActive = true
        addStackButtonsAmounts(texts: texts, stack: stack, tags: tags)
    }
    
    private func addStackButtonsAmounts(texts: [String], stack: UIStackView, tags: CountableRange<Int>) {
        for tag in tags {
            let button: UIButton = UIButton(type: .custom)
            configureUnselectedButton(button: button)
            let text = texts[tag]
            button.setTitle(text, for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(actionSelectAmount(_:)), for: .touchUpInside)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.widthAnchor.constraint(equalToConstant: buttonsWidth).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonsHeight).isActive = true
            button.accessibilityIdentifier = "mobileRecharge_numberButton"
            stack.addArrangedSubview(button)
            buttons.append(button)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .uiBackground
    }
}
