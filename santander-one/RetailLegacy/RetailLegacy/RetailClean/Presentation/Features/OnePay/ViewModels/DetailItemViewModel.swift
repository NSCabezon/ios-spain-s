class DetailItemViewModel: TableModelViewItem<DetailItemTableViewCell> {
    private let title: LocalizedStylableText
    private let info: String?
    private let isFirst: Bool
    var isLast: Bool
    private let subtitleLines: Int
    private let isCopyEnabled: Bool
    weak var toolTipDisplayer: ToolTipDisplayer?
    weak var shareDelegate: ShareInfoHandler?

    init(_ title: LocalizedStylableText, info: String?, isFirst: Bool, isLast: Bool, subtitleLines: Int = 1, isCopyEnabled: Bool, toolTipDisplayer: ToolTipDisplayer?, _ privateComponent: PresentationComponent, shareDelegate: ShareInfoHandler?) {
        self.title = title
        self.info = info
        self.isFirst = isFirst
        self.isLast = isLast
        self.subtitleLines = subtitleLines
        self.isCopyEnabled = isCopyEnabled
        self.toolTipDisplayer = toolTipDisplayer
        self.shareDelegate = shareDelegate
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: DetailItemTableViewCell) {
        viewCell.isFirst = isFirst
        viewCell.isLast = isLast
        viewCell.setTitle(title)
        viewCell.setSubtitle(info)
        viewCell.subtitleLines = subtitleLines
        viewCell.setCopyButtonHidden(!isCopyEnabled)
        viewCell.toolTipDisplayer = toolTipDisplayer
        viewCell.shareDelegate = shareDelegate
    }
    
}
