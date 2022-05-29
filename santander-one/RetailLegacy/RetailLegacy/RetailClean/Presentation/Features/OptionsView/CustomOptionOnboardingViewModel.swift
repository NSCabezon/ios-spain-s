//
//  CustomOptionOnboardingViewModel.swift
//  RetailLegacy
//
//  Created by Victor Carrilero García on 10/02/2021.
//

import Foundation

final class CustomOptionOnboardingViewModel: StackItem<CustomOptionOnboardingView> {
    // MARK: - Private attributes
    private let stringLoader: StringLoader
    private let titleKey: String
    private let descriptionKey: String
    private let imageName: String
    private weak var view: CustomOptionOnboardingView?
    private let change: ((CustomOptionOnboardingViewModel) -> Void)?
    private let switchText: String?
    private var switchState: Bool
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader,
         titleKey: String,
         descriptionKey: String,
         imageName: String,
         switchText: String? = nil,
         switchState: Bool,
         change: ((CustomOptionOnboardingViewModel) -> Void)?,
         insets: Insets = Insets(left: 0, right: 0, top: 0, bottom: 24)) {
        self.stringLoader = stringLoader
        self.switchState = switchState
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.imageName = imageName
        self.change = change
        self.switchText = switchText
        super.init(insets: insets)
    }
    
    override func bind(view: CustomOptionOnboardingView) {
        view.set(title: self.stringLoader.getString(self.titleKey),
                 description: self.stringLoader.getString(self.descriptionKey),
                 image: self.imageName)
        view.setSwitchText(self.titleLocalized)
        view.isSwitchOn = self.switchState
        view.switchValueDidChange = { [weak self] switchValue in
            self?.switchState = switchValue
            guard let strongSelf = self else { return }
            self?.change?(strongSelf)
        }
        self.view = view
    }
}

private extension CustomOptionOnboardingViewModel {
    var titleLocalized: LocalizedStylableText {
        if let title = self.switchText {
            return stringLoader.getString(title)
        } else {
            return self.switchState ? stringLoader.getString("onboarding_label_enabled") : stringLoader.getString("onboarding_label_disabled")
        }
    }
}
