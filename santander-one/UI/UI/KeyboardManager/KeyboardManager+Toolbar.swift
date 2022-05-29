//
//  KeyboardManager+Toolbar.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 17/07/2020.
//

import Foundation
import CoreFoundationLib

protocol ToolbarKeyboardDelegate: AnyObject {
    func previousKeyboardSelected(_ textfield: EditText)
    func nextKeyboardSelected(_ textfield: EditText)
    func buttonSelected(_ textfield: EditText)
}

extension KeyboardManager {
    
    typealias ToolbarConfiguration = (isNextEnabled: Bool, isPreviousEnabled: Bool, buttonConfiguration: ToolbarButtonConfiguration?)
    typealias ToolbarButtonConfiguration = (button: ToolbarButton, isEnabled: Bool)
    
    class Toolbar: UIToolbar {
        
        private var button: ToolbarButton?
        private weak var textfield: EditText?
        private weak var toolbarDelegate: ToolbarKeyboardDelegate?
        
        init(textfield: EditText, toolbarDelegate: ToolbarKeyboardDelegate) {
            self.textfield = textfield
            self.toolbarDelegate = toolbarDelegate
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupWithConfiguration(_ configuration: ToolbarConfiguration) {
            self.setupToolbar()
            var items: [UIBarButtonItem] = []
            items.append(self.previousButton(for: configuration))
            items.append(self.nextButton(for: configuration))
            if let buttonConfiguration = configuration.buttonConfiguration {
                self.button = buttonConfiguration.button
                let barButton = UIBarButtonItem(title: buttonConfiguration.button.title, style: .plain, target: self, action: #selector(self.buttonSelected))
                barButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.santander(family: .text, type: .bold, size: 16.0)], for: .normal)
                barButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.santander(family: .text, type: .bold, size: 16.0)], for: .disabled)
                barButton.isEnabled = buttonConfiguration.isEnabled
                barButton.accessibilityIdentifier = buttonConfiguration.button.accessibilityIdentifier
                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                items.append(barButton)
            } else {
                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            }
            self.setItems(items, animated: false)
        }
        
        // MARK: - Private methods
        
        @objc private func previousSelected() {
            guard let textfield = self.textfield else { return }
            self.toolbarDelegate?.previousKeyboardSelected(textfield)
        }
        
        @objc private func nextSelected() {
            guard let textfield = self.textfield else { return }
            self.toolbarDelegate?.nextKeyboardSelected(textfield)
        }
        
        @objc private func buttonSelected() {
            guard let textfield = self.textfield else { return }
            
            if self.button?.actionType == Action.continueAction {
                self.toolbarDelegate?.buttonSelected(textfield)
            }
            self.button?.action(textfield)
        }
        
        private func setupToolbar() {
            self.barStyle = .default
            self.isTranslucent = true
            self.tintColor = .white
            self.barTintColor = .santanderRed
            self.sizeToFit()
            self.isUserInteractionEnabled = true
        }
         
        private func previousButton(for configuration: ToolbarConfiguration) -> UIBarButtonItem {
            let previousButton = UIBarButtonItem(image: Assets.image(named: "icnArrowUpWhite"), style: .done, target: self, action: #selector(self.previousSelected))
            previousButton.isEnabled = configuration.isPreviousEnabled
            return previousButton
        }
        
        private func nextButton(for configuration: ToolbarConfiguration) -> UIBarButtonItem {
            let nextButton = UIBarButtonItem(image: Assets.image(named: "icnArrowDownWhite"), style: .done, target: self, action: #selector(self.nextSelected))
            nextButton.isEnabled = configuration.isNextEnabled
            return nextButton
        }
    }
}
