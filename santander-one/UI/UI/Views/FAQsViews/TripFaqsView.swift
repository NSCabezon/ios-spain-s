//
//  TripFaqsView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/03/2020.
//

import UIKit
import CoreFoundationLib

public protocol TripFaqsViewDelegate: TripFaqViewDelegate {
    func didReloadTripFaq()
}

public final class TripFaqsView: XibView {
    @IBOutlet weak var stackView: UIStackView!
    
    public weak var delegate: TripFaqsViewDelegate?
    private var style: FaqViewStyle = .tripsModeStyle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    public convenience init(style: FaqViewStyle) {
        self.init(frame: .zero)
        self.style = style
    }
    
    private func setupViews() {
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public var isEmpty: Bool {
        return stackView.arrangedSubviews.isEmpty
    }
    
    public func removeSubviews() {
        self.stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    public func setupVieModels(_ viewModels: [TripFaqViewModel]) {
        for (index, viewModel) in viewModels.enumerated() {
            self.addTripFaqView(viewModel: viewModel, identifier: "tripFaqView")
        }
        self.accessibilityIdentifier = "tripFaqsView"
    }
    
    private func addTripFaqView(viewModel: TripFaqViewModel, identifier: String) {
        let tripFaqView = TripFaqView(viewModel: viewModel, style: style)
        tripFaqView.setTopSpace(self.style.topSpace, bottomSpace: self.style.bottomSpace)
        tripFaqView.accessibilityIdentifier = identifier
        tripFaqView.delegate = delegate
        tripFaqView.tapAction = { [weak self] identifier in
            self?.closeAllTripViewsExcept(identifier)
            self?.delegate?.didReloadTripFaq()
        }
        self.stackView.addArrangedSubview(tripFaqView)
    }
    
    private func closeAllTripViewsExcept(_ viewIdentifier: String) {
        self.stackView.arrangedSubviews.forEach {
            if $0.accessibilityIdentifier != viewIdentifier {
                ($0 as? TripFaqView)?.close()
            }
        }
    }
}

public struct TripFaqViewModel {
    public var iconName: String
    private var titleKey: String
    private var descriptionKey: String
    private var highlightedDescriptionKey: String
    
    public init(iconName: String, titleKey: String, descriptionKey: String, highlightedDescriptionKey: String = "", baseURL: String = "") {
        self.iconName = baseURL + iconName
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.highlightedDescriptionKey = highlightedDescriptionKey
    }
    
    public init(dto: FaqDTO, baseURL: String) {
        self.iconName = baseURL + (dto.icon ?? "")
        self.titleKey = dto.question
        self.descriptionKey = dto.answer
        self.highlightedDescriptionKey = ""
    }
    
    public var title: LocalizedStylableText {
        return localized(self.titleKey)
    }
    
    public var description: LocalizedStylableText {
        return localized(self.descriptionKey)
    }
    
    public func isHighlighted() -> Bool {
        return !highlightedDescriptionKey.isEmpty
    }
    
    public var highlightedDescription: LocalizedStylableText {
        return description
    }
    
    func highlight(_ baseString: NSAttributedString?) -> NSAttributedString {
        guard let baseString = baseString else { return NSAttributedString() }
        let ranges = baseString.string
            .ranges(of: highlightedDescriptionKey.trim())
            .map { NSRange($0, in: highlightedDescriptionKey) }
        return ranges.reduce(NSMutableAttributedString(attributedString: baseString)) {
            $0.addAttribute(.backgroundColor, value: UIColor.lightYellow, range: $1)
            return $0
        }
    }
}
