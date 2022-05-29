//
//  OTPCodeView.swift
//  UI
//
//  Created by alvola on 24/06/2020.
//

import UIKit
import CoreFoundationLib

public final class OTPCodeView: UIView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("login_title_otpPush")
        label.textAlignment = .left
        label.font = UIFont.santander(type: .bold, size: 16.0)
        label.textColor = UIColor.lisboaGray
        addSubview(label)
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.santander(size: 12.0)
        label.textColor = UIColor.mediumSanGray
        addSubview(label)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("login_text_otpPush")
        label.textAlignment = .left
        label.font = UIFont.santander(size: 16.0)
        label.textColor = UIColor.lisboaGray
        addSubview(label)
        return label
    }()
    
    private lazy var otpField: OTPCodeField = {
        let view = OTPCodeField()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private lazy var progressBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightSanGray
        addSubview(view)
        return view
    }()
    
    private lazy var progressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkTorquoise
        progressBackgroundView.addSubview(view)
        return view
    }()
    
    private lazy var progressViewWidth: NSLayoutConstraint = {
        let width = progressView.trailingAnchor.constraint(equalTo: self.progressBackgroundView.trailingAnchor)
        return width
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.santander(size: 14.0)
        label.textColor = UIColor.mediumSanGray
        addSubview(label)
        return label
    }()

    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.santander(size: 11.0)
        label.textColor = UIColor.mediumSanGray
        label.configureText(withKey: "login_label_validFor")
        addSubview(label)
        return label
    }()
    
    private var remainingTimeForDismiss: OTPTimeViewModel? {
        didSet {
            setOTPTime(remainingTimeForDismiss, animated: oldValue != nil)
        }
    }
    private var timer: Timer?
    private var superDismissBlock: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = self.superview else { return }
        
        self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 28.0).isActive = true
        self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -28.0).isActive = true
    }
    
    public func setOTPInfo(_ info: OTPCodeViewModel) {
        otpField.setCode(info.code)
        dateLabel.text = info.formattedDate
        remainingTimeForDismiss = info.time
    }
    
    public func setOTPTime(_ time: OTPTimeViewModel?, animated: Bool) {
        guard let time = time else { return }
        currentTimeLabel.text = time.remainingTimeInMinutes
        progressViewWidth.constant = -CGFloat(time.totalTime - time.remainingTime) * (self.progressBackgroundView.frame.width / CGFloat(time.totalTime))
        guard animated else { return self.progressBackgroundView.layoutIfNeeded() }
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.progressBackgroundView.layoutIfNeeded()
        }
    }
}

private extension OTPCodeView {
    func commonInit() {
        backgroundColor = .white
        layer.cornerRadius = 6.0
        layer.borderColor = UIColor.mediumSkyGray.cgColor
        layer.borderWidth = 1.0
        
        self.heightAnchor.constraint(equalToConstant: 171.0).isActive = true
        self.addShadow(location: .bottom, opacity: 0.3, radius: 1.0, height: 2.0)
        
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.dateLabel.leadingAnchor, constant: 10.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 13.0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 23.0).isActive = true
        
        dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -13.0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0.0).isActive = true
        subtitleLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        otpField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        otpField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        otpField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 9.0).isActive = true
        otpField.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        
        progressBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        progressBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        progressBackgroundView.topAnchor.constraint(equalTo: otpField.bottomAnchor, constant: 12.0).isActive = true
        progressBackgroundView.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
        progressBackgroundView.layer.cornerRadius = 2.5
        
        progressView.leadingAnchor.constraint(equalTo: self.progressBackgroundView.leadingAnchor).isActive = true
        progressViewWidth.isActive = true
        progressView.topAnchor.constraint(equalTo: self.progressBackgroundView.topAnchor).isActive = true
        progressView.heightAnchor.constraint(equalTo: self.progressBackgroundView.heightAnchor).isActive = true
        progressView.layer.cornerRadius = progressBackgroundView.layer.cornerRadius
        
        currentTimeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0).isActive = true
        currentTimeLabel.trailingAnchor.constraint(equalTo: self.totalTimeLabel.leadingAnchor, constant: -10.0).isActive = true
        currentTimeLabel.topAnchor.constraint(equalTo: progressBackgroundView.bottomAnchor, constant: 4.0).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        totalTimeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -22.0).isActive = true
        totalTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor).isActive = true
        totalTimeLabel.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        configureAccessibilityIds()
    }
    
    func configureAccessibilityIds() {
        self.accessibilityIdentifier = "areaOTP"
        titleLabel.accessibilityIdentifier = "login_title_otpPush"
        subtitleLabel.accessibilityIdentifier = "login_text_otpPush"
        dateLabel.accessibilityIdentifier = "fecha"
        otpField.accessibilityIdentifier = "areaCode"
        progressBackgroundView.accessibilityIdentifier = "SliderBarEmpty"
        progressView.accessibilityIdentifier = "SliderBarFill"
        currentTimeLabel.accessibilityIdentifier = "hora"
        totalTimeLabel.accessibilityIdentifier = "login_label_validFor"
    }
    
    func countdownValue(_ time: Int) {
        self.remainingTimeForDismiss?.remainingTime = time
        startTimer { [weak self] _ in
            guard let self = self, self.timer != nil else { return }
            self.timer?.invalidate()
            self.timer = nil
            time > 0 ? self.countdownValue(time - 1) : self.dismiss()
        }
    }
    
    func dismiss() {
        self.dismissAction()
        self.superDismissBlock?()
    }
    
    func startTimer(completion: @escaping (Timer) -> Void) {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: completion)
    }
    
    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
}

extension OTPCodeView: StickyExpandedViewProtocol {
    public func setInfo(_ info: Any) {
        stopTimer()
        guard let time = info as? OTPTimeViewModel else {
            guard let info = info as? OTPCodeViewModel else { return }
            return setOTPInfo(info)
        }
        remainingTimeForDismiss = time
    }
}

extension OTPCodeView: ExpandedViewActionsProtocol {
    public func superDismissAction(block: @escaping () -> Void) {
        self.superDismissBlock = block
    }
    
    public func dismissAction() {
        stopTimer()
    }
    
    public func presentAction() {
        guard let time = remainingTimeForDismiss?.remainingTime else { return }
        countdownValue(time)
    }
}
