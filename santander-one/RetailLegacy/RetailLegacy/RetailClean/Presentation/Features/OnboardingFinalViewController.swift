//
//  OnboardingFinalViewController.swift
//  toTest
//
//  Created by alvola on 02/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI

protocol OnboardingFinalPresenterProtocol: OnboardingPresenterProtocol {
    func loadDigitalProfile()
    func configureDigitalProfile()
    func continueWithSettings()
}

final class OnboardingFinalViewController: BaseViewController<OnboardingFinalPresenterProtocol> {
    @IBOutlet weak var santanderIconImageView: UIImageView! {
        didSet {
            self.santanderIconImageView.image = Assets.image(named: "icnSanRedInfo")
        }
    }
    @IBOutlet weak var titleLabel: UILabel? {
        didSet {
            self.titleLabel?.numberOfLines = 0
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.titleLabel?.minimumScaleFactor = 0.5
            self.titleLabel?.textColor = UIColor.uiBlack
            self.titleLabel?.configureText(
                withKey: "onboarding_title_brilliant",
                andConfiguration: LocalizedStylableTextConfiguration(
                    font: UIFont.santanderTextRegular(size: 48),
                    alignment: .left,
                    lineHeightMultiple: 0.8,
                    lineBreakMode: .byClipping
                )
            )
        }
    }
    @IBOutlet weak var subtitleLabel: UILabel? {
        didSet {
            self.subtitleLabel?.numberOfLines = 0
            self.subtitleLabel?.adjustsFontSizeToFitWidth = true
            self.subtitleLabel?.minimumScaleFactor = 0.5
            self.subtitleLabel?.lineBreakMode = .byClipping
            self.subtitleLabel?.applyStyle(LabelStylist(textColor: UIColor.uiBlack, font: UIFont.santanderHeadlineRegular(size: 24), textAlignment: NSTextAlignment.left))
            self.subtitleLabel?.set(localizedStylableText: localized(key: "onboarding_subtitle_finishedApp"))
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel? {
        didSet {
            self.descriptionLabel?.numberOfLines = 0
            self.descriptionLabel?.adjustsFontSizeToFitWidth = true
            self.descriptionLabel?.minimumScaleFactor = 0.5
            self.descriptionLabel?.lineBreakMode = .byClipping
            self.descriptionLabel?.applyStyle(LabelStylist(textColor: UIColor.lisboaGrayNew, font: UIFont.santanderTextLight(size: 16), textAlignment: NSTextAlignment.left))
            self.descriptionLabel?.set(localizedStylableText: localized(key: "onboarding_text_selectHelp"))
            self.descriptionLabel?.set(lineHeightMultiple: 0.85)
        }
    }
    @IBOutlet weak var continueView: UIView?
    @IBOutlet weak var continueTitleLabel: UILabel? {
        didSet {
            self.continueTitleLabel?.numberOfLines = 0
            self.continueTitleLabel?.adjustsFontSizeToFitWidth = true
            self.continueTitleLabel?.minimumScaleFactor = 0.5
            self.continueTitleLabel?.lineBreakMode = .byClipping
            self.continueTitleLabel?.applyStyle(LabelStylist(textColor: UIColor.uiBlack, font: UIFont.santanderHeadlineRegular(size: 19), textAlignment: NSTextAlignment.left))
            self.continueTitleLabel?.set(localizedStylableText: localized(key: "onboarding_text_configureApp"))
        }
    }
    @IBOutlet weak var continueDescriptionLabel: UILabel? {
        didSet {
            self.continueDescriptionLabel?.numberOfLines = 0
            self.continueDescriptionLabel?.adjustsFontSizeToFitWidth = true
            self.continueDescriptionLabel?.minimumScaleFactor = 0.5
            self.continueDescriptionLabel?.lineBreakMode = .byClipping
            self.continueDescriptionLabel?.applyStyle(LabelStylist(textColor: UIColor.lisboaGrayNew, font: UIFont.santanderTextLight(size: 16), textAlignment: NSTextAlignment.left))
            self.continueDescriptionLabel?.set(localizedStylableText: localized(key: "onboarding_text_personaliseApp"))
            self.continueDescriptionLabel?.set(lineHeightMultiple: 0.85)
        }
    }
    @IBOutlet weak var continueLabel: UILabel? {
        didSet {
            self.continueLabel?.applyStyle(LabelStylist(textColor: UIColor.santanderRed, font: UIFont.santanderTextRegular(size: 14), textAlignment: NSTextAlignment.right))
            self.continueLabel?.set(localizedStylableText: localized(key: "generic_button_continue"))
        }
    }
    @IBOutlet weak var progressView: UIView?
    @IBOutlet weak var progressLabel: UILabel?
    @IBOutlet weak var currentProgress: UIView?
    @IBOutlet weak var currentProgressWidth: NSLayoutConstraint?
    @IBOutlet weak var buttonsView: BottomActionsOnboardingView?
    
    override class var storyboardName: String {
        return "Onboarding"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func prepareView() {
        super.prepareView()
        commonInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.noButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
    }
    
    @objc func reloadContent() {
        self.buttonsView?.continueText = localized(key: "onboarding_button_globalPosition")
        self.buttonsView?.backText = localized(key: "generic_button_previous")
        self.titleLabel?.set(localizedStylableText: localized(key: "onboarding_title_brilliant"))
        self.subtitleLabel?.set(localizedStylableText: localized(key: "onboarding_subtitle_finishedApp"))
        self.descriptionLabel?.set(localizedStylableText: localized(key: "onboarding_text_selectHelp"))
    }
    
    /*
     values: between 0.0 - 1.0
     */
    
    func setProgress(_ progress: Double) {
        let verified = max(0.0, min(1.0, progress))
        progressLabel?.text = String( Int( verified * 100.0 )) + "%"
        animateProgress(CGFloat(verified) * (progressView?.frame.width ?? 0.0))
        progressLabel?.accessibilityIdentifier = AccessibilityOnboarding.completedPercentageLabel
    }
    
    func configureViews(_ showDigitalProfile: Bool) {
        if !showDigitalProfile {
            self.continueView?.isHidden = true
        } else {
            self.configureLabels()
            continueView?.backgroundColor = UIColor.uiWhite
            continueView?.drawShadow(offset: CGSize(width: 0.0, height: 2.0), opaticity: 0.7, color: UIColor.lightSanGray, radius: 3.0)
            continueView?.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSkyGray)
            continueView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(continueViewDidPressed)))
            continueView?.isUserInteractionEnabled = true
            progressView?.layer.cornerRadius = (progressView?.frame.height ?? 0.0) / 2.0
            progressView?.backgroundColor = UIColor.silverDark
            currentProgress?.layer.cornerRadius = (currentProgress?.frame.height ?? 0.0) / 2.0
            currentProgress?.backgroundColor = UIColor.darkTorquoise
        }
    }
}

private extension OnboardingFinalViewController {
    func commonInit() {
        self.presenter.configureDigitalProfile()
        self.presenter.loadDigitalProfile()
        configureButtons()
    }
    
    func configureButtons() {
        if let bottomButtonsView = BottomActionsOnboardingView.instantiateFromNib(), let buttonsView = buttonsView {
            bottomButtonsView.embedInto(container: buttonsView)
            self.buttonsView = bottomButtonsView
        }
        buttonsView?.delegate = self
        buttonsView?.setupViews(true)
        buttonsView?.continueText = localized(key: "onboarding_button_globalPosition")
        buttonsView?.backText = localized(key: "generic_button_previous")
        buttonsView?.continueButton.widthAnchor.constraint(equalToConstant: 190.0).isActive = true
        buttonsView?.finishButton.widthAnchor.constraint(equalToConstant: 190.0).isActive = true
    }
    
    func configureLabels() {
        progressLabel?.applyStyle(LabelStylist(textColor: UIColor.lisboaGrayNew, font: UIFont.santanderTextRegular(size: 12), textAlignment: NSTextAlignment.left))
        progressLabel?.text = "0%"
    }
    
    @objc func continueViewDidPressed() {
        animateTap()
        presenter.continueWithSettings()
    }
    
    func animateTap() {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = 1.0
        animation.toValue = 2.0
        animation.duration = 0.1
        continueView?.layer.add(animation, forKey: "Width")
        continueView?.layer.borderWidth = 1.0
    }
    
    func animateProgress(_ value: CGFloat) {
        currentProgressWidth?.constant = value
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: - BottomActionsOnboardingViewDelegate methods
extension OnboardingFinalViewController: BottomActionsOnboardingViewDelegate {
    func backPressed() { presenter.goBack() }
    
    func continuePressed() { presenter?.goContinue() }
}

extension OnboardingFinalViewController: OnboardingClosableProtocol {}

extension OnboardingFinalViewController: OnBoardingStepView {}
