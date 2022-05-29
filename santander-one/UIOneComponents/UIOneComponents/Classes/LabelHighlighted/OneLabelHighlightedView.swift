//
//  oneLabelHighlightedView.swift
//  UIOneComponents
//
//  Created by Hernán Villamil on 18/3/22.
//

import UIKit
import UI

public enum OneLabelHighlightedStyle {
    case clear
    case lightGreen
    case paleYellow
    case custom(_ color: UIColor)
    
    public var color: UIColor {
        switch self {
        case .clear:
            return .clear
        case .lightGreen:
            return .greenIce
        case .paleYellow:
            return .onePaleYellow
        case .custom(let color):
            return color
        }
    }
    
    public static func getStyleForColor(_ color: UIColor) -> OneLabelHighlightedStyle {
        switch color {
        case .clear:
            return .clear
        case .oneLightGreen:
            return .lightGreen
        case .onePaleYellow:
            return .paleYellow
        default:
            return custom(color)
        }
    }
}

public final class OneLabelHighlightedView: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var label: UILabel!
    
    public var text: String? {
        set { label.text = newValue }
        get { label.text }
    }
    
    public var attributedText: NSAttributedString? {
        set { label.attributedText = newValue }
        get { label.attributedText }
    }
    
    public var style: OneLabelHighlightedStyle? {
        set { backgroundView.backgroundColor = newValue?.color }
        get { .getStyleForColor(backgroundView.backgroundColor ?? .clear) }
    }
    
    public override var accessibilityIdentifier: String? {
        set { label.accessibilityIdentifier = newValue }
        get { label.accessibilityIdentifier }
    }

    public override var accessibilityLabel: String? {
        set { label.accessibilityLabel = newValue }
        get { label.accessibilityLabel }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
}

private extension OneLabelHighlightedView {
    func configureView() {
        label.textColor = .oneLisboaGray
        label.font = .santander(family: .headline, type: .bold, size: 24)
        label.textAlignment = .center
        backgroundView.layer.cornerRadius = 4.0
        style = .clear
    }
}
