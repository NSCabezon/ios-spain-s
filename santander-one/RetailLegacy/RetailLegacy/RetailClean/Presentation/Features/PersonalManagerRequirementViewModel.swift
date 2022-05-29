class PersonalManagerRequirementViewModel: TableModelViewItem<PersonalManagerRequirementViewCell> {
    private let text: LocalizedStylableText
    
    init(dependencies: PresentationComponent, text: LocalizedStylableText) {
        self.text = text
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalManagerRequirementViewCell) {
        viewCell.requirementLabel.set(localizedStylableText: text)
    }
    
}
