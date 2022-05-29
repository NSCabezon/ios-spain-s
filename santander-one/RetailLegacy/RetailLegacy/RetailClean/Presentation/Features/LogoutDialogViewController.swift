import UIKit
import UI
import CoreFoundationLib

protocol LogoutDialogPresenterProtocol: Presenter {
    var remainingTimeForViewDismission: Int { get }
    var totalTimeForViewDismission: Int { get }
    func viewDidLoad()
    func didSelectLogout()
    func didSelectClose()
    func stopTimer()
    func restartTimer()
    func startDialogCountdown()
}

protocol LogoutDialogViewProtocol {
    func startCountdownProgress(_ time: Double)
    func setCountdownValue(_ string: String)
}

final class LogoutDialogViewController: BaseViewController<LogoutDialogPresenterProtocol> {
    
    // MARK: - Public attributes
    override static var storyboardName: String {
        return "LogoutDialog"
    }
    
    public var imageBannerViewModel: ImageBannerViewModel?
    
    // MARK: - Outlets
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var dialogContainerView: UIView!
    @IBOutlet private weak var progressBackgroundView: UIView!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var progressViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var countdownDescription: UILabel!
    @IBOutlet private weak var countdownLabel: UILabel!
    @IBOutlet private weak var cancelButton: RedButton!
    @IBOutlet private weak var cancelIcon: UIImageView!
    @IBOutlet private weak var bannerContainerView: UIView!
    @IBOutlet private weak var bannerContainerViewHeight: NSLayoutConstraint!
    
    private var progressAnimator: UIViewPropertyAnimator?
    
    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        configureOffer()
        self.setAccessibilityIdentifiers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appReturnedFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func prepareView() {
        super.prepareView()
        
        configureView()
        configureButton()
        configureProgressBar()
        setCountdownValue("")
        configureLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
       
    func showBanner(newHeight: Float?) {
        UIView.performWithoutAnimation {
            guard let newHeight = newHeight, newHeight > 0  else { return }
            self.bannerContainerView.isHidden = false
            self.bannerContainerViewHeight.constant = CGFloat(newHeight)
            self.bannerContainerView.setNeedsLayout()
            self.bannerContainerView.layoutIfNeeded()
            self.bannerContainerView.layoutSubviews()
            guard
                let imageViewCell = self.bannerContainerView.subviews.compactMap({ $0 as? ImageViewCell}).first
            else { return }
            imageViewCell.imageURLView.contentMode = .scaleAspectFill
        }
    }
    
    @IBAction func cancelTouched(_ sender: UIButton) {
        presenter.didSelectLogout()
    }
}

// MARK: - Private methods
private extension LogoutDialogViewController {
    
    func configureView() {
        self.dialogContainerView.isHidden = true
        gradientView.backgroundColor = UIColor.lisboaGrayNew
        gradientView.alpha = 0.7
        dialogContainerView.layer.cornerRadius = 5
        dialogContainerView.layer.masksToBounds = true
        dialogContainerView.addShadow(offset: CGSize(width: 0.0, height: 2.0),
                                      radius: 3.0,
                                      color: UIColor.black,
                                      opacity: 0.2)
        bannerContainerView.layer.cornerRadius = 5
    }
    
    func configureButton() {
        cancelIcon.image = Assets.image(named: "icnGoOutWhite")
        cancelButton.configureHighlighted(font: UIFont.santander(type: .bold, size: 16.0))
        cancelButton.set(localizedStylableText: localized(key: "generic_button_exit"), state: .normal)
    }
    
    func configureProgressBar() {
        progressBackgroundView.backgroundColor = UIColor.lightSanGray
        progressBackgroundView.layer.cornerRadius = progressBackgroundView.bounds.height / 2.0
        progressView.layer.cornerRadius = progressView.bounds.height / 2.0
        progressView.backgroundColor = UIColor.darkTorquoise
    }
    
    func configureLabel() {
        countdownDescription.font = UIFont.santander(family: .headline, size: 16.0)
        countdownDescription.textColor = UIColor.lisboaGrayNew
        countdownDescription.set(localizedStylableText: localized(key: "exit_label_disconnection"))
        
        countdownLabel.font = UIFont.santander(type: .bold, size: 19.0)
        countdownLabel.textColor = UIColor.lisboaGrayNew
    }
    
    func configureOffer() {
        guard let imagebanner = self.imageBannerViewModel else { return }
        imagebanner.configureView(in: bannerContainerView) { [weak self] in
            self?.dialogContainerView.isHidden = false
            self?.configureCloseButton()
            DispatchQueue.main.async {
                self?.presenter.startDialogCountdown()
            }
        }
    }
    
    func configureCloseButton() {
        let closeBack = UIView()
        closeBack.backgroundColor = .clear
        closeBack.translatesAutoresizingMaskIntoConstraints = false
        closeBack.isAccessibilityElement = true
        closeBack.accessibilityIdentifier = AccessibilityLogout.btnCloseWhite
        let close = UIImageView(image: Assets.image(named: "icnCloseWhite"))
        close.translatesAutoresizingMaskIntoConstraints = false
        close.isUserInteractionEnabled = false
        close.isAccessibilityElement = true
        close.accessibilityIdentifier = AccessibilityLogout.icnCloseWhite
        dialogContainerView.addSubview(closeBack)
        closeBack.addSubview(close)
        
        close.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        close.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        close.topAnchor.constraint(equalTo: dialogContainerView.topAnchor, constant: 11.0).isActive = true
        dialogContainerView.trailingAnchor.constraint(equalTo: close.trailingAnchor, constant: 16.0).isActive = true
        dialogContainerView.bringSubviewToFront(close)
        
        closeBack.widthAnchor.constraint(equalTo: close.widthAnchor, multiplier: 1.5).isActive = true
        closeBack.heightAnchor.constraint(equalTo: close.heightAnchor, multiplier: 1.5).isActive = true
        closeBack.centerYAnchor.constraint(equalTo: close.centerYAnchor).isActive = true
        closeBack.centerXAnchor.constraint(equalTo: close.centerXAnchor).isActive = true
        closeBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectClose)))
        closeBack.isUserInteractionEnabled = true
    }
    
    @objc func didSelectClose() {
        presenter.didSelectClose()
    }
    
    @objc func appMovedToBackground() {
        self.progressAnimator?.stopAnimation(true)
        self.progressAnimator = nil
        presenter.stopTimer()
        progressViewWidth.constant = -CGFloat(presenter.totalTimeForViewDismission - presenter.remainingTimeForViewDismission) * (progressBackgroundView.frame.width / CGFloat(presenter.totalTimeForViewDismission))
        self.progressBackgroundView.layoutIfNeeded()
    }
    
    @objc func appReturnedFromBackground() {
        presenter.restartTimer()
    }
    
    func setAccessibilityIdentifiers() {
        self.countdownDescription.accessibilityIdentifier = AccessibilityLogout.exitLabelDisconnection
        self.cancelButton.accessibilityIdentifier = AccessibilityLogout.btnExit
        self.dialogContainerView.accessibilityIdentifier = AccessibilityLogout.logoutPopup
        if let imageViewCell = self.bannerContainerView.subviews.compactMap({ $0 as? ImageViewCell}).first {
            imageViewCell.imageURLView.accessibilityIdentifier = AccessibilityLogout.imgOfferExit
        }
    }
}

extension LogoutDialogViewController: LogoutDialogViewProtocol {
    func startCountdownProgress(_ time: Double) {
        progressViewWidth.constant = -progressBackgroundView.frame.width
        self.progressAnimator = UIViewPropertyAnimator(duration: time, curve: .linear, animations: { [weak self] in
            self?.progressBackgroundView.layoutIfNeeded()
        })
        self.progressAnimator?.startAnimation()
    }
    
    func setCountdownValue(_ string: String) {
        countdownLabel.text = " " + string
    }
}
