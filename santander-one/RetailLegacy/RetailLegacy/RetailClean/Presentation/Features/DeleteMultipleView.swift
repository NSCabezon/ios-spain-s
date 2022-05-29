//

import UIKit

protocol DeleteMultipleViewDelegate: class {
    func selectAll()
    func delete()
    func editMode(activate: Bool)
}

class DeleteMultipleView: UIView, ViewCreatable {
    weak var delegate: DeleteMultipleViewDelegate?
    
    @IBOutlet weak var containerButtonView: UIView!
    @IBOutlet weak var deleteButton: RedButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var selectAllLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var separatorOne: UIView!
    @IBOutlet weak var separatorTwo: UIView!
    
    var editableActivated: Bool = false
    
    var buttonText: LocalizedStylableText? {
        didSet {
            if let text = buttonText {
                deleteButton.set(localizedStylableText: text.uppercased(), state: .normal)
            }
        }
    }
    
    var selectAllText: LocalizedStylableText? {
        didSet {
            if let text = selectAllText {
                selectAllLabel.set(localizedStylableText: text)
            } else {
                selectAllLabel.text = nil
            }
        }
    }
    
    var deleteText: LocalizedStylableText? {
        didSet {
            if let text = deleteText {
                deleteLabel.set(localizedStylableText: text)
            } else {
                deleteLabel.text = nil
            }
        }
    }
    
    var cancelText: LocalizedStylableText? {
        didSet {
            if let text = cancelText {
                cancelLabel.set(localizedStylableText: text)
            } else {
                cancelLabel.text = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupViews() {
        let screen = UIScreen.main
        selectAllLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: screen.isIphone4or5 ? 11.0 : 13.0), textAlignment: .center))
        deleteLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: screen.isIphone4or5 ? 11.0 : 13.0), textAlignment: .center))
        cancelLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: screen.isIphone4or5 ? 11.0 : 13.0), textAlignment: .center))
        separatorOne.backgroundColor = .sanGreyMedium
        separatorTwo.backgroundColor = .sanGreyMedium
        
        changeStatus()
    }
    
    private func changeStatus() {
        if !editableActivated {
            containerButtonView.isHidden = false
            stackView.isHidden = true
            editableActivated = true
        } else {
            containerButtonView.isHidden = true
            stackView.isHidden = false
            editableActivated = false
        }
    }
    
    @IBAction func clickSelectAllButton(_ sender: Any) {
        delegate?.selectAll()
    }
    
    @IBAction func clickDeleteButton(_ sender: Any) {
        delegate?.delete()
    }
    
    @IBAction func clickEditableToggle(_ sender: Any) {
        delegate?.editMode(activate: true)
        changeStatus()
    }
    
    @IBAction func clickCancelButton(_ sender: Any) {
        delegate?.editMode(activate: false)
        changeStatus()
    }
}
