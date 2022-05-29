//
//  File.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 19/05/2020.
//
import UIKit
import CoreFoundationLib

public class FlatSegmentedControl: UISegmentedControl {
    private var theme: FlatSegmentedTheme?

    public func setupWithTheme(theme: FlatSegmentedTheme) {
        self.theme = theme
        self.setupView()
        self.selectedSegmentIndex = 0
    }
    
    public func updateSegmentsLocalizedTextWithKeys(_ keys: [String]) {
        self.setSegments(keys)
    }
}

private extension FlatSegmentedControl {
     func applySeparatorTrick() {
        if #available(iOS 13.0, *) {
            let image = UIImage().withTintColor(.clear)
            self.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            self.selectedSegmentTintColor = theme?.backgroundColor
        } else {
            self.tintColor = .clear
        }
    }

    private func setupView() {
        guard let theme = self.theme else {
            return
        }
        self.applySeparatorTrick()
        self.backgroundColor = theme.backgroundColor
        self.clipsToBounds = true
        let selectedLabelAttributes: [NSAttributedString.Key: NSObject] = [.foregroundColor: theme.selectedTextColor,
                                                                           .font: theme.selectedTextFont]
        let unselectedLabelAttributes: [NSAttributedString.Key: NSObject] = [.foregroundColor: theme.unSelectedTextColor,
                                                                             .font: theme.unSelectedTextFont]
        self.setTitleTextAttributes(unselectedLabelAttributes, for: .normal)
        self.setTitleTextAttributes(selectedLabelAttributes, for: .selected)
        self.setBackgroundImage(selectedItemImage(), for: .normal, barMetrics: .default)
        self.setBackgroundImage(selectedItemImage(), for: .selected, barMetrics: .default)
    }

     func setSegments(_ values: [String]) {
        self.removeAllSegments()
        for (index, key) in values.enumerated() {
          self.insertSegment(withTitle: localized(key), at: index, animated: false)
        }
    }
    
    private func selectedItemImage() -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }
}
