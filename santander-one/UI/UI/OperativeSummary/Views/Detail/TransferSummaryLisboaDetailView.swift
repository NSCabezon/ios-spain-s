import CoreFoundationLib
import UIKit

public final class TransferSummaryLisboaDetailView: XibView {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var leftBorder: UIView!
    @IBOutlet private weak var bankImage: UIImageView!
    @IBOutlet private weak var rightBorder: UIView!
    @IBOutlet private weak var infoLabel: UILabel!
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setViewModel(_ viewModel: OperativeSummaryLisboaDetailViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.attributedText = viewModel.subtitle
        if let info = viewModel.info {
            self.infoLabel.text = info
            self.infoLabel.isHidden = false
        } else {
            self.infoLabel.isHidden = true
        }
        if let bankIcon = viewModel.baseUrl {
            let iban = IBANEntity.create(fromText: viewModel.info ?? "")
            self.set(self.bankIconPath(with: iban, baseUrl: bankIcon))
        }
        setAccessibilityIds(viewModel.accessibilityIdentifier)
    }
}

private extension TransferSummaryLisboaDetailView {
    func setupView() {
        backgroundColor = .skyGray
        separatorView.backgroundColor = .mediumSkyGray
        titleLabel.textColor = .grafite
        titleLabel.font = .santander(family: .text, type: .regular, size: 13)
        subtitleLabel.textColor = .lisboaGray
        subtitleLabel.font = .santander(family: .text, type: .bold, size: 14)
        leftBorder.backgroundColor = .mediumSkyGray
        rightBorder.backgroundColor = .mediumSkyGray
        infoLabel.font = .santander(family: .text, type: .regular, size: 12.0)
        infoLabel.textColor = .mediumSanGray
        self.bankImage.isHidden = true
    }
    
    func set(_ bankIconUrl: String?) {
        self.bankImage.isAccessibilityElement = true
        self.bankImage.isHidden = false
        guard let bankIconUrl = bankIconUrl else { return }
        self.bankImage.loadImage(urlString: bankIconUrl)
    }
    
    func bankIconPath(with iban: IBANEntity, baseUrl: String) -> String? {
        guard let entityCode = iban.ibanElec.substring(4, 8) else { return nil }
        let countryCode = iban.countryCode
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    func setAccessibilityIds(_ identifier: String) {
        accessibilityIdentifier = identifier 
        titleLabel.accessibilityIdentifier = identifier + "_title"
        subtitleLabel.accessibilityIdentifier = identifier + "_description"
        infoLabel.accessibilityIdentifier = identifier + "_infoDetail"
        bankImage.accessibilityIdentifier = identifier + "_bankImage"
    }
}
