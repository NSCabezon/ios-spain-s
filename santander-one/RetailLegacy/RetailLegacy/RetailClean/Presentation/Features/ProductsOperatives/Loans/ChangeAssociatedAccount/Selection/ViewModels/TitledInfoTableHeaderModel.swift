class TitledInfoTableHeaderModel: TableModelViewHeader<TitledInfoTableHeader> {
    var title: LocalizedStylableText?
    var tooltipText: LocalizedStylableText?
    var tooltipTitle: LocalizedStylableText?
    weak var actionDelegate: TooltipTextFieldActionDelegate?
    
    override func bind(viewHeader: TitledInfoTableHeader) {
        viewHeader.title = title
        viewHeader.tooltipText = tooltipText
        viewHeader.tooltipTitle = tooltipTitle
        viewHeader.actionDelegate = actionDelegate
    }
}
