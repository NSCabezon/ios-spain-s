import Foundation

class PhoneInputTextFieldViewModel: TableModelViewItem<PhoneInputTextFieldTableViewCell>, InputIdentificable {
    private let title: LocalizedStylableText
    let inputIdentifier: String
    var dataEntered: String?
    var titleIdentifier: String?
    var inputTextIdentifier: String?
    
    init(inputIdentifier: String,
         titleInfo: LocalizedStylableText,
         dependencies: PresentationComponent,
         titleIdentifier: String? = nil,
         inputTextIdentifier: String? = nil) {
        self.title = titleInfo
        self.inputIdentifier = inputIdentifier
        self.titleIdentifier = titleIdentifier
        self.inputTextIdentifier = inputTextIdentifier
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PhoneInputTextFieldTableViewCell) {
        viewCell.setTitle(title)
        viewCell.setTitleIdentifier(self.titleIdentifier)
        viewCell.setInputTextIdentifier(self.inputTextIdentifier)
        viewCell.newTextFieldValue = { [weak self] newValue in
            self?.dataEntered = newValue
        }
    }
}
