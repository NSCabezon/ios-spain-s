class ChangeLogVersionViewModel: GroupableCellViewModel<ChangeLogVersionViewCellItem> {
    
    var title: LocalizedStylableText?
    var value: String?
    
    init(title: LocalizedStylableText?, value: String?, isFirst: Bool, isLast: Bool, dependencies: PresentationComponent) {
        self.title = title
        self.value = value
        super.init(dependencies: dependencies)
        self.isFirst = isFirst
        self.isLast = isLast
    }
    
    override func bind(viewCell: ChangeLogVersionViewCellItem) {
        super.bind(viewCell: viewCell)
        viewCell.title = title
        viewCell.value = value
        viewCell.isFirst = isFirst
        viewCell.isLast = isLast
    }

}
