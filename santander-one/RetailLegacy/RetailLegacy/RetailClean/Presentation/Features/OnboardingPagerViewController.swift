//
//  OnboardingPagerViewController.swift
//  toTest
//
//  Created by alvola on 03/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import CoreFoundationLib
import UI

final class OnboardingPagerViewController: BaseViewController<OnboardingPresenterProtocol>, BottomActionsOnboardingViewDelegate {
    @IBOutlet weak var pagerView: PagerView?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
    }
    
    @objc func reloadContent() {
        self.buttonsView?.continueText = localized(key: "generic_button_continue")
        self.buttonsView?.backText = localized(key: "generic_button_previous")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pagerView?.setNeedsLayout()
    }
    
    func setInfo(_ info: [PageInfo], title: LocalizedStylableText, currentIndex: Int, bannedIndexes: [Int], isGlobalPosition: Bool) {
        pagerView?.delegate = self
        pagerView?.setTitle(title)
        pagerView?.setInfo(info)
        pagerView?.setBannedIndexes(bannedIndexes)
        pagerView?.setCurrentSlide(currentIndex)
        addStepLabel(isGlobalPosition)
    }
    
    func getOptionPagerSelected() -> Int {
        return pagerView?.selectedSlide().id ?? 0
    }
    
    func getSmartSelectedColor() -> ButtonType? {
        return pagerView?.themeColorSelectorView.getSelectedButtonType()
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureButtons()
        view.applyGradientBackground(colorStart: UIColor.uiWhite, colorFinish: UIColor.sky30)
        view.clipsToBounds = true
    }
    
    private func configureButtons() {
        if let bottomButtonsView = BottomActionsOnboardingView.instantiateFromNib(), let buttonsView = buttonsView {
            bottomButtonsView.embedInto(container: buttonsView)
            self.buttonsView = bottomButtonsView
        }
        buttonsView?.delegate = self
        buttonsView?.setupViews()
        buttonsView?.continueText = localized(key: "generic_button_continue")
        buttonsView?.backText = localized(key: "generic_button_previous")
    }
    
    // MARK: - BottomActionsOnboardingViewDelegate methods
    
    func backPressed() { presenter.goBack() }
    
    func continuePressed() { presenter.goContinue() }
    
    func addStepLabel(_ isGlobalPosition: Bool) {}
}

extension OnboardingPagerViewController: OnboardingClosableProtocol {}

extension OnboardingPagerViewController: PagerViewDelegate {
    func scrolledToNewOption() {
        presenter.scrolledToNewOption()
    }
}

extension OnboardingPagerViewController: OnBoardingStepView {}

