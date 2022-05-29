import UIKit

class PersonalAreaSwitchTableCell: SpaceGroupableTableViewCell {
    
    var title: LocalizedStylableText? {
        didSet {
            if let title = title {
                titleLabel.set(localizedStylableText: title)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var value: Bool {
        get {
            return switchView.isOn
        }
        set {
            switchView.isOn = newValue
        }
    }
    
    var switchValueChanged: ((Bool) -> Void)?
    
    override var roundedView: UIView {
        return containerView
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var switchView: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
//        let restrictedUse = true
//        switchView.isEnabled = !restrictedUse
    }
    
    func updateSwitchValue() {
        switchView.setOn(!switchView.isOn, animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchValueChanged?(switchView.isOn)
    }
}
