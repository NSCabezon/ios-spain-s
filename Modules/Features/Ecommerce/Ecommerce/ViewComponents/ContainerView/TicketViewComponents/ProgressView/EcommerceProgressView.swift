import UIKit
import UI
import ESCommons
import CoreFoundationLib

public protocol EcommerceProgressViewDelegate: AnyObject {
    func progressViewDidFinish()
}

public final class EcommerceProgressView: XibView {
    @IBOutlet private weak var remainingTimeTitleLabel: UILabel!
    @IBOutlet private weak var remainingTimeLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    
    var identifier: String {
        return String(describing: self)
    }
    
    var remainingTimeForDismiss: EcommerceTimeViewModel? {
        didSet {
            setOTPTime(remainingTimeForDismiss, animated: oldValue != nil)
        }
    }
        
    private var timer: Timer?

    weak var delegate: EcommerceProgressViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ info: EcommerceTimeViewModel) {
        self.remainingTimeForDismiss = info
        self.countdownValue(info.remainingTime)
        self.remainingTimeTitleLabel.configureText(withKey: localized("ecommerce_label_timeRemaining"))
        self.remainingTimeLabel.text = info.remainingTimeInMinutes
    }
    
    func resetView() {
        self.remainingTimeForDismiss = nil
    }
    
    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
}

private extension EcommerceProgressView {
    func setupView() {
        self.backgroundColor = .clear
        self.setTitle()
        self.setDescription()
        self.setProgressView()
        self.setAccessibilityIds()
    }
    
    func setTitle() {
        self.remainingTimeTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 12)
        self.remainingTimeTitleLabel.textColor = .grafite
        self.remainingTimeTitleLabel.textAlignment = .left
    }
    
    func setDescription() {
        self.remainingTimeLabel.font = UIFont.santander(family: .text, type: .bold, size: 14)
        self.remainingTimeLabel.textColor = .lisboaGray
        self.remainingTimeLabel.textAlignment = .right
    }
    
    func setProgressView() {
        self.progressView.roundCorners(corners: .allCorners, radius: 12)
        self.progressView.progressTintColor = .darkTurqLight
        self.progressView.transform = progressView.transform.scaledBy(x: 1, y: 1.5)
    }
    
    func setOTPTime(_ time: EcommerceTimeViewModel?, animated: Bool) {
        guard let time = time else { return }
        self.remainingTimeLabel.text = time.remainingTimeInMinutes
        let progress = Float(time.remainingTime) / Float(time.totalTime)
        self.progressView.setProgress(progress, animated: animated)
    }
    
    func countdownValue(_ time: Int) {
        self.remainingTimeForDismiss?.remainingTime = time
        self.startTimer { [weak self] _ in
            guard let self = self, self.timer != nil else { return }
            self.timer?.invalidate()
            self.timer = nil
            time > 0 ? self.countdownValue(time - 1) : self.countdownDidFinish()
        }
    }
    
    // MARK: - Timer
    func countdownDidFinish() {
        delegate?.progressViewDidFinish()
    }
    
    func startTimer(completion: @escaping (Timer) -> Void) {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 1.0, repeats: false, block: completion)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    func setAccessibilityIds() {
        self.remainingTimeTitleLabel.accessibilityIdentifier = AccessibilityEcommerceProgressView.titleLabel
        self.remainingTimeLabel.accessibilityIdentifier = AccessibilityEcommerceProgressView.remainingLabel
        self.progressView.accessibilityIdentifier = AccessibilityEcommerceProgressView.progressView
        self.accessibilityIdentifier = AccessibilityEcommerceProgressView.baseView
    }
}
