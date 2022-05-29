import UIKit
import CoreFoundationLib

class DigitalProfileView: ResponsiveView {
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        
        return stack
    }()
    
    private let topStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 0
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
        
        return label
    }()
    
    private var subtitleLabel: UILabel  = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        
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
        subtitleLabel.applyStyle(LabelStylist(textColor: .darkTorquoise, font: UIFont.santanderTextRegular(size: 12), textAlignment: .left))
        percentageLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santanderTextRegular(size: 12), textAlignment: .center))
        containerStackView.embedInto(container: self)
        containerStackView.addArrangedSubview(topStackView)
        topStackView.addArrangedSubview(progressView)
        topStackView.addArrangedSubview(percentageLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        progressView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.74).isActive = true
        percentageLabel.heightAnchor.constraint(equalToConstant: 17.5).isActive = true
        self.setAccessibilityIdentifiers()
    }
    
    func resetProgress() {
        progressView.setProgress(0.0, animated: true)
    }
    
    func setPercentage(value: Float, text: String) {
        percentageLabel.text = text
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
            self?.progressView.setProgress(value, animated: true)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0.4, options: .curveEaseIn, animations: { [weak self] in
                self?.percentageLabel.alpha = 1.0
            }, completion: nil)
        })
        
    }
    
    func setSubTitle(_ subtitle: LocalizedStylableText?) {
        subtitleLabel.set(localizedStylableText: subtitle ?? .empty)
    }
    
    func setAccessibilityIdentifiers() {
        self.progressView.accessibilityIdentifier = AccessibilitySideMenu.progressView
        self.percentageLabel.accessibilityIdentifier = AccessibilitySideMenu.percentageLabel
        self.subtitleLabel.accessibilityIdentifier = AccessibilitySideMenu.digitalProfileLabel
    }
}
