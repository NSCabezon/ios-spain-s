class PersonalManagerOfferNoSubtitleViewModel: TableModelViewItem<PersonalManagerOfferNoSubtitleViewCell> {
    private let titleLabel: LocalizedStylableText
    private let type: PersonalManagerOfferType
    
    init(dependencies: PresentationComponent, titleLabel: LocalizedStylableText, type: PersonalManagerOfferType) {
        self.titleLabel = titleLabel
        self.type = type
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalManagerOfferNoSubtitleViewCell) {
        viewCell.titleLabel.set(localizedStylableText: titleLabel)
        viewCell.setImage(type: type)
    }
}
