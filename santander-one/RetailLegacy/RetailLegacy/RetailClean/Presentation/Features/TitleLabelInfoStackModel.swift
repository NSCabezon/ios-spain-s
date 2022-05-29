class TitleLabelInfoStackModel: StackItem<TitleLabelInfoStackView> {
    private let title: LocalizedStylableText
    private let tooltipText: LocalizedStylableText?
    private let tooltipTitle: LocalizedStylableText?
    private weak var actionDelegate: TooltipTextFieldActionDelegate?

    init(title: LocalizedStylableText, tooltipText: LocalizedStylableText, tooltipTitle: LocalizedStylableText, actionDelegate: TooltipTextFieldActionDelegate, insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 4)) {
        self.title = title
        self.tooltipText = tooltipText
        self.tooltipTitle = tooltipTitle
        self.actionDelegate = actionDelegate
        super.init(insets: insets)
    }
    
    override func bind(view: TitleLabelInfoStackView) {
        view.setTitle(title: title, accessibilityIdentifier: view.accessibilityIdentifier)
        view.tooltipText = tooltipText
        view.tooltipTitle = tooltipTitle
        view.actionDelegate = actionDelegate
    }
}
