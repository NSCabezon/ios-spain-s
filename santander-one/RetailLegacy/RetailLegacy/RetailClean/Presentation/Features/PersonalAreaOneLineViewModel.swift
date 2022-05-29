import UIKit

class PersonalAreaOneLineViewModel: GroupableCellViewModel<PersonalAreaOneLineTableViewCell> {
    
    var text: LocalizedStylableText
    
    override var height: CGFloat? {
        return nil
    }
    
    init(text: LocalizedStylableText, dependencies: PresentationComponent) {
        self.text = text
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PersonalAreaOneLineTableViewCell) {
        super.bind(viewCell: viewCell)
        viewCell.setTitle(text)
    }
}
