//
//  TripFaqView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/03/2020.
//

import UIKit
import CoreFoundationLib

public protocol TripFaqViewDelegate: AnyObject {
    func didExpandAnswer(question: String)
    func didTapAnswerLink(question: String, url: URL)
}

final class TripFaqView: XibView, UITextViewDelegate {
    weak var delegate: TripFaqViewDelegate?
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var arrowImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var arrowImageTrailing: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSeparatorConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSeparatorLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageSeparationConstraint: NSLayoutConstraint!

    private var style: FaqViewStyle
    public var tapAction: ((String) -> Void)?
    
    init(frame: CGRect, style: FaqViewStyle) {
        self.style = style
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder, style: FaqViewStyle) {
        self.style = style
        super.init(coder: coder)
        self.setup()
    }
    
    convenience init(viewModel: TripFaqViewModel, style: FaqViewStyle) {
        self.init(frame: .zero, style: style)
        
        configureImageWithName(viewModel.iconName)
        configureLabels(viewModel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setTopSpace(_ topSpace: CGFloat, bottomSpace: CGFloat) {
        topSeparatorConstraint.constant = topSpace
        bottomSeparatorConstraint.constant = bottomSpace
    }
    
    public func close() {
        guard !descriptionContainerView.isHidden else { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.descriptionContainerView.isHidden = true
            self?.arrowImageView.transform = CGAffineTransform.identity
            self?.stackView.layoutIfNeeded()
        }
    }
    
    private func setup() {
        self.arrowImageView.image = Assets.image(named: style.arrowIcon)
        self.arrowImageViewHeight.constant = style.arrowHeight
        self.arrowImageTrailing.constant = style.arrowTrailing
        self.setFonts()
        self.descriptionContainerView.isHidden = true
        self.descriptionTextView.delegate = self
        self.separatorView.backgroundColor = .mediumSkyGray
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bottomSeparatorLeadingMarginConstraint.constant = style.separatorMargin
        self.setAccessibilityIdentifiers()
    }
    
    private func configureImageWithName(_ name: String) {
        guard style.withIcon else { return hideImageIcon(true) }
        self.iconImageView.image = Assets.image(named: name)
        guard self.iconImageView.image == nil else { return }
        self.iconImageView.loadImage(urlString: name) { [weak self] in
            DispatchQueue.main.async {
                self?.hideImageIcon(self?.iconImageView.image == nil)
                self?.layoutIfNeeded()
            }
        }
    }
    
    private func configureLabels(_ viewModel: TripFaqViewModel) {
        self.titleLabel.configureText(withLocalizedString: viewModel.title)
        self.descriptionTextView.configureText(withLocalizedString: viewModel.description, andConfiguration: nil)
        guard viewModel.isHighlighted() else { return }
        self.titleLabel.attributedText = viewModel.highlight(self.titleLabel.attributedText)
        self.descriptionTextView.attributedText = viewModel.highlight(self.descriptionTextView.attributedText)
    }
    
    private func hideImageIcon(_ hide: Bool) {
        self.imageWidthConstraint.constant = hide ? 0.0 : 42.0
        self.imageSeparationConstraint.constant = hide ? 9.0 : 14.0
    }
    
    private func setFonts() {
        self.titleLabel.font = self.style.font
        self.titleLabel.textColor = UIColor.lisboaGray
        self.descriptionTextView.font = .santander(type: .light, size: 14)
        self.descriptionTextView.textColor = UIColor.lisboaGray
    }
    
    @IBAction func didTapOnTip() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.descriptionContainerView.isHidden.toggle()
            if !self.descriptionContainerView.isHidden {
                self.delegate?.didExpandAnswer(question: self.titleLabel.text ?? "")
            }
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: CGFloat(Double.pi))
            self.arrowImageView.accessibilityIdentifier = self.descriptionContainerView.isHidden ? "icnArrowDown" : "icnArrowUp"
            self.stackView.layoutIfNeeded()
            self.tapAction?(self.accessibilityIdentifier ?? "")
        })
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.delegate?.didTapAnswerLink(question: titleLabel.text ?? "", url: URL)
        return true
    }
    
    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "tipFaq_view"
        self.titleLabel.accessibilityIdentifier = "tipFaq_title"
        self.descriptionTextView.accessibilityIdentifier = "tipFaq_desc"
        self.iconImageView.accessibilityIdentifier = "tipFaq_icn"
    }
}

public enum FaqViewStyle {
    case tripsModeStyle
    case globalSearchStyle
    
    var topSpace: CGFloat {
        switch self {
        case .tripsModeStyle:
            return 16.0
        case .globalSearchStyle:
            return 15.0
        }
    }
    
    var bottomSpace: CGFloat {
        switch self {
        case .tripsModeStyle:
            return 22.0
        case .globalSearchStyle:
            return 13.0
        }
    }
    
    var font: UIFont {
        switch self {
        case .tripsModeStyle:
            return UIFont.santander(type: .bold, size: 18.0)
        case .globalSearchStyle:
            return UIFont.santander(size: 15.0)
        }
    }
    
    var separatorMargin: CGFloat {
        switch self {
        case .tripsModeStyle:
            return 0.0
        case .globalSearchStyle:
            return 17.0
        }
    }
    
    var withIcon: Bool {
        switch self {
        case .tripsModeStyle:
            return true
        case .globalSearchStyle:
            return false
        }
    }
    
    var arrowIcon: String {
        switch self {
        case .tripsModeStyle:
            return "icnArrowDown"
        case .globalSearchStyle:
            return "icnArrowDownSearch"
        }
    }
    
    var arrowHeight: CGFloat {
        switch self {
        case .tripsModeStyle:
            return 24.0
        case .globalSearchStyle:
            return 16.0
        }
    }
    
    var arrowTrailing: CGFloat {
        switch self {
        case .tripsModeStyle:
            return -3.5
        case .globalSearchStyle:
            return 0.0
        }
    }
}
