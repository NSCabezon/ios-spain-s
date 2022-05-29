enum CheckStackModelValues: String {
    case checkFalse = "false"
    case checkTrue = "true"
}

class CheckStackModel: StackItem<CheckStackView>, InputEditableIdentificable {
    let inputIdentifier: String
    private var isSelected: Bool
    private let title: LocalizedStylableText
    private let showLine: Bool
    private var checkChanged: ((_ selected: Bool) -> Void)?
    private var setCheckValue: ((Bool) -> Void)?

    // MARK: - Public methods
    
    init(inputIdentifier: String, title: LocalizedStylableText, isSelected: Bool = false, showLine: Bool = false, insets: Insets = Insets(left: 13, right: 10, top: 0, bottom: 8), checkChanged: ((_ selected: Bool) -> Void)? = nil) {
        self.inputIdentifier = inputIdentifier
        self.title = title
        self.isSelected = isSelected
        self.showLine = showLine
        self.checkChanged = checkChanged
        super.init(insets: insets)
    }
    
    override func bind(view: CheckStackView) {
        view.setSelected(isSelected)
        view.setTitle(title)
        view.delegate = self
        setCheckValue = view.setCheckValue
        showLineIfNeed(view)
    }
    
    private func showLineIfNeed(_ view: CheckStackView) {
        (showLine == true) ? view.showLine() : view.hideLine()
    }
    
    func setCurrentValue(_ value: String) {
        switch CheckStackModelValues(rawValue: value) {
        case .checkFalse?:
            isSelected = false
            setCheckValue?(false)
        case .checkTrue?:
            isSelected = true
            setCheckValue?(true)
        case .none:
            break
        }
    }
}

extension CheckStackModel: CheckStackViewDelegate {
    func checkStackViewDidSelect() {
        isSelected = !isSelected
        checkChanged?(isSelected)
    }
}
