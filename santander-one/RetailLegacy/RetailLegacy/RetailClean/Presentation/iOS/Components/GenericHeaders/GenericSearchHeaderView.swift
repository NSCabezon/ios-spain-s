import UIKit
import UI

class GenericSearchHeaderView: BaseViewHeader {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: CoachmarkUIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var clearButton: UIButton!
    var searchAction: (() -> Void)?
    var clearAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 15), textAlignment: .left))
        separatorView.backgroundColor = .lisboaGray
        contentView.backgroundColor = .uiWhite
        searchButton.setImage(Assets.image(named: "incSearch"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
    }

    func setTitle(_ text: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: text)
    }
    
    override func getContainerView() -> UIView? {
        return nil
    }
    
    override func draw() {
    }
    
    func setButtonCoachmarkId(_ coachmarkId: CoachmarkIdentifier?) {
        searchButton.coachmarkId = coachmarkId
    }
    
    func setClearButtonVisible(_ isVisible: Bool) {
        clearButton.isHidden = !isVisible
    }
    
    @objc func searchPressed() {
        searchAction?()
    }
    
    @objc func clearPressed() {
        clearAction?()
    }
}
