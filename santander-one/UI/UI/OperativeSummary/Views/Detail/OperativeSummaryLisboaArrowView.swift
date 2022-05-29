import CoreFoundationLib
import UIKit

public protocol OperativeSummaryLisboaArrowViewDelegate: AnyObject {
    func arrowPressed(colapsed: Bool)
}

public final class OperativeSummaryLisboaArrowView: XibView {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var leftBorder: UIView!
    @IBOutlet private weak var rightBorder: UIView!
    @IBOutlet private weak var bottomBorder: UIView!
    @IBOutlet private weak var infoLabel: UILabel!
    public weak var delegate: OperativeSummaryLisboaArrowViewDelegate?
    private var colapsed = true
    
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
        titleLabel.accessibilityIdentifier = viewModel.accessibilityIdentifier
        subtitleLabel.attributedText = viewModel.subtitle
        subtitleLabel.accessibilityIdentifier = viewModel.accessibilityIdentifier + "_description"
        if let info = viewModel.info {
            self.infoLabel.text = info
            self.infoLabel.isHidden = false
        } else {
            self.infoLabel.isHidden = true
        }
    }
    
    public func addBorders() {
        bottomBorder.backgroundColor = colapsed ? .clear : .mediumSkyGray
    }
}

private extension OperativeSummaryLisboaArrowView {
    @IBAction func arrowPressed(_ sender: UIButton) {
        checkStatus()
        delegate?.arrowPressed(colapsed: colapsed)
    }
    
    func setupView() {
        backgroundColor = .skyGray
        separatorView.backgroundColor = .mediumSkyGray
        titleLabel.textColor = .grafite
        titleLabel.font = .santander(family: .text, type: .regular, size: 13)
        subtitleLabel.textColor = .lisboaGray
        subtitleLabel.font = .santander(family: .text, type: .bold, size: 14)
        imageView.image = Assets.image(named: "imgTornBig")
        button.setBackgroundImage(Assets.image(named: "icnOvalArrowDown"), for: .normal)
        button.accessibilityIdentifier = colapsed ? "icn_ovalArrowDown" : "icnOvalButtonUp"
        button.accessibilityLabel = localized(AccessibilityTransfers.moreInfoButton)
        leftBorder.backgroundColor = .mediumSkyGray
        rightBorder.backgroundColor = .mediumSkyGray
        infoLabel.font = .santander(family: .text, type: .regular, size: 12.0)
        infoLabel.textColor = .mediumSanGray
    }
    
    func checkStatus() {
        colapsed.toggle()
        imageView.isHidden = !colapsed
        button.transform = colapsed ? .identity : CGAffineTransform(rotationAngle: .pi)
    }
}
