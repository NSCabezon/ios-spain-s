class OnePayTransferSelectorViewModel: TableModelViewItem<OnePayTransferSelectorCell> {
    
    var leftText: String
    var rightText: String?
    let accessibilityIdentifierLeft: String?
    let accessibilityIdentifierRight: String?
    let shouldBeNavigatable: Bool
    
    // MARK: - Public methods
    
    init(leftText: String, rightText: String? = nil, accessibilityIdentifierLeft: String? = nil, accessibilityIdentifierRight: String? = nil, shouldBeNavigatable: Bool, dependencies: PresentationComponent) {
        self.leftText = leftText
        self.rightText = rightText
        self.shouldBeNavigatable = shouldBeNavigatable
        self.accessibilityIdentifierLeft = accessibilityIdentifierLeft
        self.accessibilityIdentifierRight = accessibilityIdentifierRight
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OnePayTransferSelectorCell) {
        viewCell.configure(left: leftText, right: rightText, displayIcon: shouldBeNavigatable, accessibilityIdentifierLeft: self.accessibilityIdentifierLeft,
                           accessibilityIdentifierRight: self.accessibilityIdentifierRight)
    }
}
