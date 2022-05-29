class SegmentStackModel: StackItem<SegmentStackView> {
    var didSelectOption: ((Int) -> Void)?
    var options: [String]
    var currentOption: Int?
    
    init(options: [String], insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 8)) {
        self.options = options
        super.init(insets: insets)
    }
    
    override func bind(view: SegmentStackView) {
        view.options(options)
        view.didSelectOptionCompletion = { [weak self] index in
            self?.didSelectOption?(index)
        }
        if let currentOption = currentOption {
            view.selectOption(currentOption)
        }
    }
}
