import Foundation

class OpinatorManagerViewModel: TableModelViewItem<PersonalManagerOpinatorViewCell> {
    
    private let title: LocalizedStylableText
    private let delegate: PersonalManagerOpinatorViewDelegate
    
    init(title: LocalizedStylableText, delegate: PersonalManagerOpinatorViewDelegate, presentation: PresentationComponent) {
        self.title = title
        self.delegate = delegate
        super.init(dependencies: presentation)
    }
    
    override func bind(viewCell: PersonalManagerOpinatorViewCell) {
        viewCell.delegate = delegate
        viewCell.opinatorButton.set(localizedStylableText: title, state: .normal)
    }
}
