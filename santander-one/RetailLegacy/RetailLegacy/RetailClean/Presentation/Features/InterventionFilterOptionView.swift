import UIKit

class InterventionFilterOptionView: UIView {
    static var xibVersion: InterventionFilterOptionView {
        let nib = Bundle.module?.loadNibNamed("InterventionFilterOptionView", owner: nil, options: nil)
        guard let view = nib?.first as? InterventionFilterOptionView else {
            fatalError("Casting failed")
        }
        return view
    }
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var selectionButton: ResponsiveButton!
    @IBOutlet weak var separator: UIView!
}
