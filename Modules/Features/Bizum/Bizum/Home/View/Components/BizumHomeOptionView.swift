import UI

protocol BizumHomeOptionViewDelegate: class {
    func didSelectOption(_ option: BizumHomeOptionViewModel?)
}

final class BizumHomeOptionView: XibView {
    weak var delegate: BizumHomeOptionViewDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    private var option: BizumHomeOptionViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func set(_ viewModel: BizumHomeOptionViewModel) {
        self.option = viewModel
        self.titleLabel.set(localizedStylableText: viewModel.title)
        self.subtitleLabel.set(localizedStylableText: viewModel.subtitle)
        self.iconImage.image = viewModel.icon
        self.actionButton.accessibilityIdentifier = viewModel.identifier
        self.titleLabel.accessibilityIdentifier = viewModel.identifier + BizumHomeOptionViewComponent.bizumTitle
        self.subtitleLabel.accessibilityIdentifier = viewModel.identifier + BizumHomeOptionViewComponent.bizumSubTitle
        self.arrowImage.accessibilityIdentifier = viewModel.identifier + BizumHomeOptionViewComponent.bizumImage
    }
}

private extension BizumHomeOptionView {
    @IBAction func didSelectButton() {
        self.delegate?.didSelectOption(self.option)
    }
    
    func setupView() {
        self.backgroundColor = UIColor.skyGray
        self.view?.backgroundColor = UIColor.white
        let shadowConfiguration = ShadowConfiguration(color: .mediumSkyGray,
                                                opacity: 0.7,
                                                radius: 2,
                                                withOffset: 1,
                                                heightOffset: 2)
        self.view?.drawRoundedBorderAndShadow(with: shadowConfiguration,
                                        cornerRadius: 5,
                                        borderColor: .lightSkyBlue,
                                        borderWith: 1)
        self.arrowImage.image = Assets.image(named: "icnArrowRight")
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.subtitleLabel.textColor = .mediumSanGray
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 14)
    }
}
