import UIKit

class PhoneCellViewModel: GroupableCellViewModel<PhoneTableViewCell> {
    
    var titleText: String?
    var subtitleText: String?
    var phone1: String?
    var phone2: String?
    var callPhone1: (() -> Void)?
    var callPhone2: (() -> Void)?
    var titleLabelCoachmarkId: CoachmarkIdentifier?
    
    init(title: String?, subtitle: String?, phone1: String?, phone2: String?, dependencies: PresentationComponent) {
        self.titleText = title
        self.subtitleText = subtitle
        self.phone1 = phone1
        self.phone2 = phone2
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PhoneTableViewCell) {
        super.bind(viewCell: viewCell)
        viewCell.setTitle(titleText)
        viewCell.setSubtitle(subtitleText)
        viewCell.setPhone1(phone1)
        viewCell.setPhone2(phone2)
        viewCell.didSelectPhone1 = callPhone1
        viewCell.didSelectPhone2 = callPhone2
        viewCell.titleLabelCoachmarkId = titleLabelCoachmarkId
    }
    
}
