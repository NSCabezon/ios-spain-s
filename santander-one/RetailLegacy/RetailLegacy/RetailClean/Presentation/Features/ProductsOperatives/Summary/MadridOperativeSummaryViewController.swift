import UI
import UIKit
import CoreFoundationLib
import Operative

protocol MadridOperativeSummaryViewProtocol {
    func addLocations(_ viewModels: [OperativeSummaryStandardLocationViewModel])
}

typealias SimpleSummaryCell = SummaryItemViewConfigurator<SimpleSummaryItemView, SimpleSummaryData>

class MadridOperativeSummaryViewController: BaseViewController<MadridOperativeSummaryPresenterProtocol> {
   
    override class var storyboardName: String {
        return "MadridOperativeSummary"
    }
    
    var summaryTitle: LocalizedStylableText? {
        didSet {
            if let text = summaryTitle {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var summarySubtitle: LocalizedStylableText? {
        didSet {
            if let text = summarySubtitle {
                subtitleLabel.set(localizedStylableText: text)
            } else {
                subtitleLabel.text = nil
            }
        }
    }
    
    var summaryInfo: [SummaryItem]? {
        didSet {
            updateSummaryInfo()
        }
    }
    
    var summaryIconImage: String? {
        didSet {
            guard let summaryIconImage = summaryIconImage else { return }
            iconImage.image = Assets.image(named: summaryIconImage)
        }
    }
    
    var additionalMessage: LocalizedStylableText? {
        didSet {
            if let message = additionalMessage {
                additionalMessageTop.constant = xibAdditionalMessageTop
                additionalMessageLabel.set(localizedStylableText: message)
            } else {
                additionalMessageTop.constant = 10.0
                additionalMessageLabel.text = nil
            }
        }
    }
            
    var sharingText: String?
    
    var continueButtonTitle: LocalizedStylableText? {
        didSet {
            if let title = continueButtonTitle {
                continueButton.set(localizedStylableText: title, state: .normal)
            } else {
                continueButton.setTitle(nil, for: .normal)
            }
        }
    }
    
    func addAdditionalButton(title: LocalizedStylableText, action: @escaping () -> Void) {
        additionalButton.isHidden = false
        additionalButton.set(localizedStylableText: title, state: .normal)
        additionalButton.onTouchAction = { _ in
            action()
        }
        self.additionalButton.accessibilityIdentifier = title.text
    }

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var scrollContainer: UIView!
    @IBOutlet private weak var summaryInfoStackView: UIStackView!
    @IBOutlet private weak var additionalMessageTop: NSLayoutConstraint!
    @IBOutlet private weak var additionalMessageLabel: UILabel!
    @IBOutlet private weak var actionsStackView: UIStackView!
    @IBOutlet private weak var locationsStackView: UIStackView!
    @IBOutlet private weak var opinatorButton: OpinatorButton!
    @IBOutlet private weak var opinatorLabel: UILabel!
    @IBOutlet private weak var pdfLabel: UILabel!
    @IBOutlet private weak var opinatorView: UIView!
    @IBOutlet private weak var pdfView: UIView!
    @IBOutlet private weak var opinatorImage: UIImageView!
    @IBOutlet private weak var pdfImage: UIImageView!
    @IBOutlet private weak var extraOpinatorButton: UIButton!
    @IBOutlet private weak var pdfButton: UIButton!
    @IBOutlet private weak var sharingContainer: UIView!
    @IBOutlet private weak var sharingContainerHeight: NSLayoutConstraint!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var buttonContainer: UIView!
    @IBOutlet private weak var continueButton: RedButton!
    @IBOutlet private weak var additionalButton: WhiteButton!
    
    private var xibAdditionalMessageTop: CGFloat!
    private var sharingContainerDefaultHeight: CGFloat?
    
    private struct Constants {
        struct InfoItemsSeparator {
            static let color: UIColor = .lisboaGray
            static let height: CGFloat = 1.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackButton(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hideBackButton(true, animated: false)
        self.enablePopGestureRecognizer(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.enablePopGestureRecognizer(true)
    }
        
    override func prepareView() {
        super.prepareView()
        self.navigationController?.navigationBar.setNavigationBarColor(.uiBackground)
        scrollView.backgroundColor = .clear
        self.titleLabel.accessibilityIdentifier =  AccessibilityMobileRecharge.summarySuccessLabel.rawValue
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 19.0)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15.0)))
        subtitleLabel.accessibilityIdentifier = AccessibilityMobileRecharge.summarySuccessSubTitle.rawValue
        xibAdditionalMessageTop = additionalMessageTop.constant
        additionalMessage = nil
        additionalMessageLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14.0)))
        
        opinatorButton.accessibilityIdentifier = AccessibilityMobileRecharge.summaryBtnImprove.rawValue
        opinatorButton.setup(buttonStylist: ButtonStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0), backgroundColor: .uiWhite))
        opinatorButton.setAccessibilityIdentifiers(titleIdentifier: "summaryBtnImproveTitle", imageIdentifier: "summaryBtnImproveImage")
        
        sharingContainerDefaultHeight = sharingContainerHeight.constant
        sharingContainerHeight.constant = 0.0
        separator.backgroundColor = .lisboaGray
        
        (continueButton as UIButton).applyStyle(ButtonStylist(textColor: .uiWhite, font: .latoMedium(size: 16)))
        continueButton.onTouchAction = { [weak self] button in
            self?.presenter.continueButtonTouched()
        }
        self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
        
        scrollContainer.backgroundColor = .clear
        scrollView.backgroundColor = .uiBackground
        
        pdfView.drawRoundedAndShadowed()
        opinatorView.drawRoundedAndShadowed()
        
        extraOpinatorButton.isExclusiveTouch = true
        pdfButton.isExclusiveTouch = true
        
        let fontConstant: CGFloat = UIDevice.current.isSmallScreenIphone ? 14.0 : 16.0
        opinatorLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontConstant), textAlignment: .center))
        pdfLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontConstant), textAlignment: .center))
        opinatorImage.image = Assets.image(named: "icnLikeRetail")
        pdfImage.image = Assets.image(named: "icnPdfButton")
        setAccessibilityIdentifiers()
    }
    
    func showOpinator(title: LocalizedStylableText) {
        opinatorView.isHidden = true
        pdfView.isHidden = true
        opinatorButton.isHidden = false
        opinatorButton.update(imageName: "icnLikeRetail", title: title)
        opinatorButton.onTouchAction = { [weak self] button in
            self?.presenter.opinatorButtonTouched()
        }
    }
    
    func showPdf(title: LocalizedStylableText) {
        opinatorView.isHidden = true
        pdfView.isHidden = true
        opinatorButton.isHidden = false
        opinatorButton.update(imageName: "icnPdfButton", title: title)
        opinatorButton.onTouchAction = { [weak self] button in
            self?.presenter.pdfButtonTouched()
        }
    }
    
    func notShowOpinatorAndPdf() {
        opinatorView.isHidden = true
        pdfView.isHidden = true
        opinatorButton.isHidden = true
    }
    
    func showOpinatorAndPdf(opinator: LocalizedStylableText, pdf: LocalizedStylableText) {
        opinatorButton.isHidden = true
        opinatorView.isHidden = false
        pdfView.isHidden = false
        opinatorLabel.set(localizedStylableText: opinator)
        pdfLabel.set(localizedStylableText: pdf)
    }
    
    func addSharingView() {
        sharingContainerHeight.constant = sharingContainerDefaultHeight ?? 0.0
        sharingContainer.backgroundColor = .clear
        let sharingViewController = presenter.shareView
        addChild(sharingViewController)
        sharingViewController.view.frame = sharingContainer.bounds
        sharingContainer.addSubview(sharingViewController.view)
        sharingViewController.didMove(toParent: self)
    }
    
    private func updateSummaryInfo() {
        summaryInfo?.forEach({ item in
            guard let itemView = UINib(nibName: item.nibName, bundle: .module).instantiate(withOwner: nil, options: nil).first as? UIView else {
                return
            }
            item.configure(view: itemView)
            summaryInfoStackView.addArrangedSubview(itemView)
            summaryInfoStackView.addArrangedSubview(createSeparator())
        })
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Constants.InfoItemsSeparator.color
        separator.heightAnchor.constraint(equalToConstant: Constants.InfoItemsSeparator.height).isActive = true
        
        return separator
    }
    
    private func setAccessibilityIdentifiers() {
        opinatorImage.isAccessibilityElement = true
        setAccessibility { self.opinatorImage.isAccessibilityElement = false }
        opinatorImage.accessibilityIdentifier = "opinatorImage"
        opinatorLabel.accessibilityIdentifier = "opinatorLabel"
        additionalMessageLabel.accessibilityIdentifier = "blockCard_aditionalMessage"
    }
        
    @IBAction func pdfButtonTouched() {
        presenter?.pdfButtonTouched()
    }
    
    @IBAction func opinatorButtonTouched() {
        presenter?.opinatorButtonTouched()
    }
}

extension MadridOperativeSummaryViewController: MadridOperativeSummaryViewProtocol {
    func addLocations(_ viewModels: [OperativeSummaryStandardLocationViewModel]) {
        for model in viewModels {
            let view = OperativeSummaryStandardLocationView(model)
            locationsStackView.addArrangedSubview(view)
        }
    }
}

extension MadridOperativeSummaryViewController: BackNotAvailableViewProtocol {}
extension MadridOperativeSummaryViewController: AccessibilityCapable {}
