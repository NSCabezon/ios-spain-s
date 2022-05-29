//
//  BizumActionButton.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 14/12/2020.
//

import UI
import CoreFoundationLib
import ESUI

protocol BizumActionButtonDelegate: class {
    func didTapOnButtonWithViewModel(_ viewModel: BizumAvailableActionViewModel)
}

public class BizumActionButton: UIDesignableView {
    private let btnAngleBracket = ESAssets.image(named: "icnArrowRightSlimGrafite9Pt")
    
    @IBOutlet weak private var leftImageView: UIImageView!
    @IBOutlet weak private var rightImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var button: UIButton!
    weak var delegate: BizumActionButtonDelegate?
    private var viewModel: BizumAvailableActionViewModel?
    public override func getBundleName() -> String {
        return "Bizum"
    }

    public override func commonInit() {
        super.commonInit()
        self.setupView()
        self.setAccessibilityIdentifiers()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.setAccessibilityIdentifiers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setAccessibilityIdentifiers()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.setAccessibilityIdentifiers()
    }
    
    func setupView() {
        self.button.titleLabel?.text = ""
        self.titleLabel.textColor = .darkTorquoise
        self.drawBorder(cornerRadius: 4, color: .mediumSkyGray, width: 1.0)
        if let bracketImage = btnAngleBracket {
            self.rightImageView.image = bracketImage
        }
        self.button.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
    }
    
    func setViewModel(_ viewModel: BizumAvailableActionViewModel) {
        self.viewModel = viewModel
        if let optionalImage = ESAssets.image(named: viewModel.iconName) {
            self.leftImageView.image = optionalImage
        }
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0), alignment: .left)
        self.titleLabel.configureText(withLocalizedString: localized(viewModel.literalKey), andConfiguration: configuration)
        self.button.accessibilityIdentifier = viewModel.accessibilityIdentifier
    }
}

private extension BizumActionButton {
    @objc func didTapOnButton() {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnButtonWithViewModel(viewModel)
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = BizumActionButtonComponent.bizumTitleLabel
    }
}
