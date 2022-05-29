class SubscriptionOperativeLabelTableModelView: TableModelViewItem<SubscriptionOperativeLabelTableViewCell> {
    
    var value: String?
    
    override func bind(viewCell: SubscriptionOperativeLabelTableViewCell) {
        viewCell.advise = value
    }
}
