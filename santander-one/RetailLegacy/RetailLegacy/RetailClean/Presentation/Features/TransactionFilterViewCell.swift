import UIKit
import UI

class TransactionFilterViewCell: BaseViewCell {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterButton: CoachmarkUIButton!
    @IBOutlet weak var pdfButton: CoachmarkUIButton!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var clearButton: UIButton!
    
    var didSelectFilter: (() -> Void)?
    var didSelectPDF: (() -> Void)?
    var didSelectClear: (() -> Void)?
    
    var isClearAvailable: Bool {
        get {
            return !clearButton.isHidden
        }
        set {
            clearButton.isHidden = !newValue
        }
    }
    
    var isPdfAvailable: Bool {
        get {
            return !pdfButton.isHidden
        }
        set {
            pdfButton.isHidden = !newValue
        }
    }
    
    var isFilterAvailable: Bool {
        get {
            return !filterButton.isHidden
        }
        set {
            filterButton.isHidden = !newValue
        }
    }
    
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var filterButtonCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.filterButton.coachmarkId
        } set {
            self.filterButton.coachmarkId = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 15.0)))
        bottomSeparator.backgroundColor = .lisboaGray
        backgroundColor = .clear
        clearButton.isHidden = true
        clearButton.isExclusiveTouch = true
        filterButton.isExclusiveTouch = true
        filterButton.setImage(Assets.image(named: "incSearch"), for: .normal)
        pdfButton.setImage(Assets.image(named: "icnPdfButton"), for: .normal)
    }
    
    @IBAction func didTouchFilterButton(_ sender: UIButton) {
        didSelectFilter?()
    }
    
    @IBAction func didTouchPdfButton(_ sender: Any) {
        didSelectPDF?()
    }
    
    @IBAction func didTouchClearButton(_ sender: UIButton) {
        didSelectClear?()
    }
}
