//
//  GraphColumnView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 29/3/22.
//

import Foundation
import UI
import UIKit
import OpenCombine
import CoreFoundationLib

enum GraphColumnViewState: State {
    case didTapColumn(_ column: GraphColumnView)
}

protocol GraphColumnViewRepresentable {
    var horizontalMargin: CGFloat { get }
    var mainBarHeight: CGFloat { get }
    var secondaryBarheight: CGFloat? { get }
    var barWidth: CGFloat { get }
    var darkColor: UIColor { get }
    var color: UIColor { get }
    var labelText: String { get }
}

final class GraphColumnView: XibView {
    
    @IBOutlet private weak var mainBarView: UIView!
    @IBOutlet private weak var secondaryBarView: UIView!
    @IBOutlet private weak var barLabel: UILabel!
    @IBOutlet private weak var mainBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var secondaryBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var barWidthConstraint: NSLayoutConstraint!
    private var subject = PassthroughSubject<GraphColumnViewState, Never>()
    public var publisher: AnyPublisher<GraphColumnViewState, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var representable: GraphColumnViewRepresentable?
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                setSelected()
            } else {
                setUnSelected()
            }
        }
    }
    
    private var height: CGFloat? {
        return representable?.mainBarHeight ?? 0
    }
    private var secondaryHeight: CGFloat? {
        return representable?.secondaryBarheight ?? 0
    }
    private let defaultCornerRadius: CGFloat = 4.0
    private var color: UIColor? {
        return representable?.color ?? .black
    }
    private var darkColor: UIColor {
        return representable?.darkColor ?? .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setAppearance()
    }
    
    func setInfo(_ representable: GraphColumnViewRepresentable) {
        self.representable = representable
        self.setHeights(mainBarHeight: representable.mainBarHeight, secondaryBarHeight: representable.secondaryBarheight)
        self.rightMarginConstraint.constant = representable.horizontalMargin
        self.updateMargins(representable.horizontalMargin)
        self.leftMarginConstraint.constant = representable.horizontalMargin
        self.barWidthConstraint.constant = representable.barWidth
        isSelected = false
        setAppearance()
    }
    
    func setmainBarAccessibilityIdentifier(_ barIdentifier: String, labelIdentifier: String? = nil) {
        mainBarView.accessibilityIdentifier = barIdentifier
        barLabel.accessibilityIdentifier = labelIdentifier
    }
    
    func setSecondaryBarAccessibilityIdentifier(_ barIdentifier: String, labelIdentifier: String? = nil) {
        secondaryBarView.accessibilityIdentifier = barIdentifier
        barLabel.accessibilityIdentifier = labelIdentifier
    }
}

private extension GraphColumnView {
    
    func setHeights(mainBarHeight: CGFloat, secondaryBarHeight: CGFloat?) {
        mainBarHeightConstraint.constant = mainBarHeight
        secondaryBarHeightConstraint.constant = secondaryBarHeight ?? 0.0
    }
    
    func setupView() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        self.barLabel.font = .typography(fontName: .oneB200Regular)
        self.barLabel.textColor = .brownishGray
    }
    
    func setSelectedLabel() {
        self.barLabel.font = .typography(fontName: .oneB200Bold)
        self.barLabel.textColor = .lisboaGray
    }
    
    func setUnSelectedLabel() {
        self.barLabel.font = .typography(fontName: .oneB200Regular)
        self.barLabel.textColor = .brownishGray
    }
    
    func setAppearance() {
        mainBarView.roundCorners(corners: [.topLeft, .topRight], radius: defaultCornerRadius)
        mainBarView.layer.borderWidth = 1.0
        mainBarView.layer.borderColor = darkColor.cgColor
        mainBarView.clipsToBounds = true
        secondaryBarView.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        secondaryBarView.backgroundColor = .clear
        secondaryBarView.addLineDashedStroke(pattern: [3, 3], radius: defaultCornerRadius, color: darkColor, fillColor: color)
        secondaryBarView.layer.masksToBounds = true
        setLabelText(representable?.labelText)
        setNeedsLayout()
    }
    
    func setLabelText(_ text: String?) {
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]
        self.barLabel?.attributedText = NSMutableAttributedString(string: text ?? "", attributes: attributes)
    }
    
    func setLightAppearance(to view: UIView) {
        view.layer.borderColor = darkColor.cgColor
        view.backgroundColor = color
    }
    
    func setDarkAppearance(to view: UIView) {
        view.backgroundColor = darkColor
        view.clipsToBounds = true
    }
    
    @objc func didTapView() {
        isSelected.toggle()
        subject.send(.didTapColumn(self))
    }
    
    func setSelected() {
        setDarkAppearance(to: mainBarView)
        setSelectedLabel()
        secondaryBarView.isHidden = false
    }
    
    func setUnSelected() {
        setLightAppearance(to: mainBarView)
        setUnSelectedLabel()
        secondaryBarView.isHidden = true
    }
    
    func updateMargins(_ constant: CGFloat) {
        [rightMarginConstraint, leftMarginConstraint].forEach { $0?.constant = constant }
    }
}
