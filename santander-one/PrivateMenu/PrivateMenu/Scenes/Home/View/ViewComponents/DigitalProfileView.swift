import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain

final class DigitalProfileView: ResponsiveView {
    private enum Constants {
        static let stackViewSpacing: CGFloat = 5
        static let labelsFontSize: CGFloat = 12
        static let progressViewHeightConstraint: CGFloat = 3
        static let progressViewWidthConstraint: CGFloat = 0.74
        static let percentageLabelHeightConstraint: CGFloat = 17.5
        static let totalPercentage: Double = 100
        static let percentageAnimationDuration: Double = 0.4
        static let percentageCompletionAnimationDuration: Double = 0.2
        static let percentageLabelAlpha: Double = 1
    }
    
    private var anySubscriptions = Set<AnyCancellable>()
    let subject = PassthroughSubject<Double, Never>()
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        
        return stack
    }()
    
    private lazy var topStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = Constants.stackViewSpacing
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return stack
    }()
    
    private var progressView: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = .darkTorquoise
        progressBar.trackTintColor = .lightSanGray
        progressBar.setContentHuggingPriority(.required, for: .horizontal)

        return progressBar
    }()
    
    private var percentageLabel: UILabel  = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.font = .santander(family: FontFamily.text,
                                type: .regular,
                                size: Constants.labelsFontSize)
        label.textColor = .lisboaGray
        label.textAlignment = .left
        return label
    }()
    
    private var subtitleLabel: UILabel  = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.font = .santander(family: FontFamily.text,
                                type: .regular,
                                size: Constants.labelsFontSize)
        label.textColor = .darkTorquoise
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        containerStackView.embedInto(container: self)
        containerStackView.addArrangedSubview(topStackView)
        topStackView.addArrangedSubview(progressView)
        topStackView.addArrangedSubview(percentageLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        progressView.heightAnchor.constraint(equalToConstant: Constants.progressViewHeightConstraint).isActive = true
        progressView.widthAnchor.constraint(equalTo: widthAnchor,
                                            multiplier: Constants.progressViewWidthConstraint).isActive = true
        percentageLabel.heightAnchor.constraint(equalToConstant: Constants.percentageLabelHeightConstraint).isActive = true
        self.setAccessibilityIdentifiers()
        bind()
    }
    
    func resetProgress() {
        progressView.setProgress(.zero, animated: true)
    }
    
    func setPercentage(_ percentage: Double) {
        let value = Float(percentage/Constants.totalPercentage)
        let text = "\(Int(percentage))%"
        percentageLabel.text = text
        UIView.animate(withDuration: Constants.percentageAnimationDuration,
                       delay: .zero,
                       options: .curveEaseIn,
                       animations: { [weak self] in
            self?.progressView.setProgress(value, animated: true)
        }, completion: { _ in
            UIView.animate(withDuration: Constants.percentageCompletionAnimationDuration,
                           delay: Constants.percentageAnimationDuration,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                self?.percentageLabel.alpha = Constants.percentageLabelAlpha
            }, completion: nil)
        })
        
    }
    
    func setSubTitle(_ subtitle: LocalizedStylableText?) {
        subtitleLabel.configureText(withLocalizedString: subtitle ?? .empty)
    }
    
    func setSubtitleWithKey(_ subtitleKey: String) {
        subtitleLabel.configureText(withKey: subtitleKey)
    }
    
    func bind() {
        subject
            .sink { [unowned self] percentageElem in
                setPercentage(percentageElem)
            }.store(in: &anySubscriptions)
    }
    
    func setAccessibilityIdentifiers() {
        self.progressView.accessibilityIdentifier = AccessibilitySideMenu.progressView
        self.percentageLabel.accessibilityIdentifier = AccessibilitySideMenu.percentageLabel
        self.subtitleLabel.accessibilityIdentifier = AccessibilitySideMenu.digitalProfileLabel
    }
}
