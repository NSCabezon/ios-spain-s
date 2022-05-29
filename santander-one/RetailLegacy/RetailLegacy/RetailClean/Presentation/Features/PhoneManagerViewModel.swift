//

import Foundation

class PhoneManagerViewModel: TableModelViewItem<PersonalManagerCallViewCell> {
    
    private let title: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    private let phoneNumber: String
    private let note: LocalizedStylableText?
    private let delegate: PersonalManagerCallViewDelegate
    private let index: Int
    
    init(title: LocalizedStylableText, subtitle: LocalizedStylableText, phoneNumber: String, note: LocalizedStylableText?, index: Int, delegate: PersonalManagerCallViewDelegate, presentation: PresentationComponent) {
        self.title = title
        self.subtitle = subtitle
        self.phoneNumber = phoneNumber
        self.note = note
        self.index = index
        self.delegate = delegate
        super.init(dependencies: presentation)
    }
    
    override func bind(viewCell: PersonalManagerCallViewCell) {
        viewCell.title.set(localizedStylableText: title)
        viewCell.subtitle.set(localizedStylableText: subtitle)
        viewCell.phoneNumberButton.setTitle(phoneNumber, for: .normal)
        viewCell.delegate = delegate
        viewCell.phoneNumberButton.tag = index
        viewCell.phoneIconButton.tag = index
        if let note = note {
            viewCell.noteLabel.set(localizedStylableText: note)
        } else {
            viewCell.noteLabel.text = nil
        }
    }
}
