import UIKit
import UI
import CoreFoundationLib

final public class CardSubscriptionDetailGlobalEmptyView: XibView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var singleEmptyView: SingleEmptyView!
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension CardSubscriptionDetailGlobalEmptyView {
    func setupView() {
        backgroundColor = .skyGray
        setTitleLabel()
        setSingleEmptyView()
    }
    
    func setTitleLabel() {
        let textConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14), lineHeightMultiple: 0.75)
        titleLabel.configureText(withKey: "m4m_label_evolutionAndAnalysis", andConfiguration: textConfiguration)
    }
    
    func setSingleEmptyView() {
        singleEmptyView.centerView()
        singleEmptyView.titleFont(.santander(family: .headline, type: .regular, size: 18), color: .brownishGray)
        singleEmptyView.updateTitle(localized("generic_label_emptyError"))
        singleEmptyView.backgroundColor = .clear
    }
}
