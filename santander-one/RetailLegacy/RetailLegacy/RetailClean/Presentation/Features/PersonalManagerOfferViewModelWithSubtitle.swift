class PersonalManagerOfferViewModelWithSubtitle: TableModelViewItem<PersonalManagerOfferViewCellWithSubtitle> {
    private let titleLabel: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    private let type: PersonalManagerOfferType
    
    init(dependencies: PresentationComponent, titleLabel: LocalizedStylableText, subtitle: LocalizedStylableText, type: PersonalManagerOfferType) {
        self.titleLabel = titleLabel
        self.subtitle = subtitle
        self.type = type
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalManagerOfferViewCellWithSubtitle) {
        viewCell.titleLabel.set(localizedStylableText: titleLabel)
        viewCell.subtitleLabel.set(localizedStylableText: subtitle)
        viewCell.setImage(type: type)
    }
}
