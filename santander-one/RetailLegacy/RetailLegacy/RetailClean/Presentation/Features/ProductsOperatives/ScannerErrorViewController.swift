import UIKit
import UI
import CoreFoundationLib

protocol ScannerErrorPresenterProtocol: Presenter {
    var errorTitle: LocalizedStylableText { get }
    var errorDescription: LocalizedStylableText { get }
    var viewTitle: LocalizedStylableText { get }
    var scanAgainTitle: LocalizedStylableText { get }
    var manualTitle: LocalizedStylableText { get }
    func userDidSelectScanAgain()
    func userDidSelectManual()
    func userDidSelectBack()
}

class ScannerErrorViewController: BaseViewController<ScannerErrorPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var errorTitleLabel: UILabel!
    @IBOutlet private weak var descriptionTitleLabel: UILabel!
    @IBOutlet private weak var scanAgainButton: WhiteButton!
    @IBOutlet private weak var manualButton: RedButton!
    @IBOutlet weak var closeImage: UIImageView!
    
    override class var storyboardName: String {
        return "BillAndTaxesOperative"
    }
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        errorTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 19.0)))
        descriptionTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15.0)))
        guard let presenter = presenter else { return }
        title = presenter.viewTitle.text
        errorTitleLabel.set(localizedStylableText: presenter.errorTitle)
        descriptionTitleLabel.set(localizedStylableText: presenter.errorDescription)
        scanAgainButton.set(localizedStylableText: presenter.scanAgainTitle, state: .normal)
        manualButton.set(localizedStylableText: presenter.manualTitle, state: .normal)
        let backImage = (Assets.image(named: "icnArrowBack") ?? UIImage()).withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backTapped))
        closeImage.image = Assets.image(named: "circleKo")
    }
    
    // MARK: - Private methods
    
    @IBAction private func scanAgainTapped(_ sender: UIButton) {
        presenter?.userDidSelectScanAgain()
    }
    
    @IBAction private func manualTapped(_ sender: UIButton) {
        presenter?.userDidSelectManual()
    }
    
    @objc private func backTapped() {
        presenter?.userDidSelectBack()
    }
}

extension ScannerErrorViewController: ForcedRotatable {
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .portrait
    }
}
