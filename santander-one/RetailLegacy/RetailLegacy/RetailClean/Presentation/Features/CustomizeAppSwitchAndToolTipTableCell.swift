//

import UIKit

class CustomizeAppSwitchAndToolTipTableCell: CustomizeAppToolTipTableCell {
    var value: Bool {
        get {
            return switchView.isOn
        }
        set {
            switchView.isOn = newValue
        }
    }
    var switchValueChanged: ((Bool) -> Void)?
    @IBOutlet private var switchView: UISwitch!
    
    func updateSwitchValue() {
        switchView.setOn(!switchView.isOn, animated: true)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchView.isOn = true//TODO: Actualmente no puede cambiar de valor, en un futuro si.
        switchValueChanged?(switchView.isOn)
    }
}
