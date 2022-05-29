//
//  OneFilter.swift
//  UIOneComponents
//
//  Created by Carlos Monfort Gómez on 21/9/21.
//

import UIKit
import CoreFoundationLib
import UI

@IBDesignable public class OneFilterView: UISegmentedControl {
    private lazy var sortedSegments: [UIView] = []
    private var style: OneFilterStyle = .defaultOneFilterStyle
    private var isDoubleLineEnabled: Bool = false
    public override var selectedSegmentIndex: Int {
        didSet {
            self.segmentsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func setupSimple(with localizedKeys: [String], withStyle style: OneFilterStyle? = nil, withIndex selectedSegmentIndex: Int = 0) {
        if let style = style { self.style = style }
        self.setSegments(localizedKeys)
        self.setAccessibilityIdentifiers(localizedKeys)
        self.setupView()
        self.selectedSegmentIndex = selectedSegmentIndex
        if #available(iOS 13, *) {
            self.bgImageForSelected()
        }
    }

    public func setupDouble(with localizedKeys: [String], accessibilityHints: [String]? = nil, withStyle style: OneFilterStyle? = nil, withIndex selectedSegmentIndex: Int = 0) {
        if let style = style { self.style = style }
        self.setSegments(localizedKeys)
        self.setAccessibilityHints(accessibilityHints)
        self.setAccessibilityIdentifiers(localizedKeys)
        self.isDoubleLineEnabled = true
        self.setupView()
        self.selectedSegmentIndex = selectedSegmentIndex
    }
}

private extension OneFilterView {
    func setupView() {
        self.configureTextAttributes()
        self.configureDesignAccordingVersion()
        self.clipsToBounds = true
    }

    func setSegments(_ values: [String]) {
        self.removeAllSegments()
        values.enumerated().forEach({ (index, item) in
            self.insertSegment(withTitle: localized(item), at: index, animated: false)
        })
        self.sortedSegments = self.subviews
    }
    
    func setAccessibilityIdentifiers(_ accessibilityIdentifiers: [String]? = nil) {
        guard let accessibilityIdentifiers = accessibilityIdentifiers,
              self.sortedSegments.count == accessibilityIdentifiers.count
            else { return }
        self.sortedSegments.enumerated().forEach {
            $0.element.accessibilityIdentifier = accessibilityIdentifiers[$0.offset]
        }
    }
    
    func setAccessibilityHints(_ accessibilityHints: [String]? = nil) {
        guard let accessibilityHints = accessibilityHints,
              self.sortedSegments.count == accessibilityHints.count else { return }
        self.sortedSegments.enumerated().forEach {
            $0.element.accessibilityHint = accessibilityHints[$0.offset]
        }
    }

    func configureTextAttributes() {
        self.setTitleTextAttributes(self.style.unselectedLabelAttributes, for: .normal)
        self.setTitleTextAttributes(self.style.selectedLabelAttributes, for: .selected)
    }

    func configureDesignAccordingVersion() {
        self.backgroundColor = self.style.backgroundColor
        self.setOneCornerRadius(type: self.style.oneCornerRadiusType)
        self.layer.borderColor = self.style.segmentBorderColor.cgColor
        self.layer.borderWidth = self.style.segmentBorderWidth
        self.applyDesign()
        self.addTarget(self, action: #selector(segmentsLayout), for: .allEvents)
        self.addTarget(self, action: #selector(segmentsLayout), for: .valueChanged)
    }

    func applyDesign() {
        if #available(iOS 13.0, *) {
            let image = UIImage().withTintColor(.clear)
            self.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            self.selectedSegmentTintColor = self.style.selectedColor
        } else {
            self.tintColor = .clear
        }
    }

    @objc func segmentsLayout() {
        self.sortedSegments.enumerated().forEach { index, item in
            if index == self.selectedSegmentIndex {
                item.setOneCornerRadius(type: self.style.oneCornerRadiusType)
            }
            item.backgroundColor = index == self.selectedSegmentIndex ? self.style.selectedColor : self.style.unselectedColor
            item.setOneShadows(type: index == self.selectedSegmentIndex ? self.style.oneShadowsType : .none)
            if self.isDoubleLineEnabled {
                self.makeDoubleLine()
            } else {
                item.subviews.first(where: { $0 is UILabel })?.frame.size = item.frame.size
            }
        }
    }

    func makeDoubleLine() {
        sortedSegments.enumerated().forEach { (index, item) in
            item.subviews.forEach({ itemView in
                guard let label = itemView as? UILabel else { return }
                label.numberOfLines = 2
                let fontType: FontType = self.selectedSegmentIndex == index ? .bold : .regular
                label.font = UIFont.santander(family: .micro, type: fontType, size: 14)
                label.textAlignment = .center
                label.set(lineHeightMultiple: 0.75)
                label.lineBreakMode = .byTruncatingTail
                itemView.frame.size = item.frame.size
            })
        }
        setNeedsLayout()
        layoutIfNeeded()
    }

    func bgImageForSelected() {
        setBackgroundImage(selectedItemImage(), for: .normal, barMetrics: .default)
        setBackgroundImage(selectedItemImage(), for: .selected, barMetrics: .default)
        setDividerImage(selectedItemImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    func selectedItemImage() -> UIImage {
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
