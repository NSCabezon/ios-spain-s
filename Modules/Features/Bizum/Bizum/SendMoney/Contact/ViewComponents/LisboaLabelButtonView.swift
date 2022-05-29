import UI
import ESUI

class LisboaLabelButtonView: XibView {
    
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var pressedButton: UIButton!
    @IBOutlet weak private var addImageView: UIImageView!
    var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: LisboaLabelButtonViewModel) {
        self.nameLabel.set(localizedStylableText: viewModel.title)
    }
    
    @IBAction func pressedButton(_ sender: UIButton) {
        action?()
    }
}

private extension LisboaLabelButtonView {
    func setAppearance() {
        self.nameLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .darkTorquoise)
        self.addImageView.image = ESAssets.image(named: "icnAdd")
        self.addImageView.accessibilityIdentifier = AccessibilityBizumContact.bizumBtnAdd
    }
}
