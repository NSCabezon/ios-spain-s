//
//  BottomSheetBasicView.swift
//  UIOneComponents
//
//  Created by Serrano gomez, Antonio on 16/03/2022.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib

public struct BottomSheetBasicConfiguration {
    let titleKey: String?
    let titleFont: UIFont?
    let titleColor: UIColor?
    let bodyKey: String?
    let bodyFont: UIFont?
    let bodyColor: UIColor?
    let bodyAttributed: NSAttributedString?
    
    public init(titleKey: String? = nil,
                titleFont: UIFont? = nil,
                titleColor: UIColor? = nil,
                bodyKey: String? = nil,
                bodyFont: UIFont? = nil,
                bodyColor: UIColor? = nil,
                bodyAttributed: NSAttributedString? = nil) {
        self.titleKey = titleKey
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.bodyKey = bodyKey
        self.bodyFont = bodyFont
        self.bodyColor = bodyColor
        self.bodyAttributed = bodyAttributed
    }
}

final class BottomSheetBasicView: DesignableView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    override func commonInit() {
        super.commonInit()
        self.contentView?.fullFit()
    }
    
    public func show(in viewController: UIViewController,
                     type: SizablePresentationType = .half(),
                     component: BottomSheetComponent = .all,
                     config: BottomSheetBasicConfiguration,
                     imageAccessibilityLabel: String? = nil,
                     btnCloseAccessibilityLabel: String? = nil) {
        setTitle(config)
        setBody(config)
        BottomSheet().show(in: viewController,
                           type: type,
                           component: component,
                           view: self,
                           imageAccessibilityLabel: imageAccessibilityLabel,
                           btnCloseAccessibilityLabel: btnCloseAccessibilityLabel)
    }
}

private extension BottomSheetBasicView {
    enum BottomSheetBasicViewConstants {
        static let defaultTitleFont: UIFont = .typography(fontName: .oneH300Bold)
        static let defaultTitleColor: UIColor = .oneLisboaGray
        static let defaultBodyFont: UIFont = .typography(fontName: .oneB400Regular)
        static let defaultBodyColor: UIColor = UIColor.oneLisboaGray
    }
    
    func setTitle(_ config: BottomSheetBasicConfiguration) {
        self.titleLabel.isHidden = config.bodyKey == nil
        self.titleLabel.font = config.titleFont ?? BottomSheetBasicViewConstants.defaultTitleFont
        self.titleLabel.textColor = config.titleColor ?? BottomSheetBasicViewConstants.defaultTitleColor
        self.titleLabel.text = localized(config.titleKey ?? "")
        self.titleLabel.textAlignment = .center
        self.titleLabel.accessibilityIdentifier = config.titleKey
    }
    
    func setBody(_ config: BottomSheetBasicConfiguration) {
        self.messageLabel.isHidden = config.bodyKey == nil && config.bodyAttributed == nil
        if let message = config.bodyKey {
            self.messageLabel.font = config.bodyFont ?? BottomSheetBasicViewConstants.defaultBodyFont
            self.messageLabel.textColor = config.bodyColor ?? BottomSheetBasicViewConstants.defaultBodyColor
            self.messageLabel.text = localized(message)
            self.messageLabel.textAlignment = .center
        } else if let message = config.bodyAttributed {
            self.messageLabel.attributedText = message
        }
        self.messageLabel.accessibilityIdentifier = config.bodyKey
    }
}
