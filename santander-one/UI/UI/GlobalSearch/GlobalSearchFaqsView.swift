//
//  GlobalSearchFaqsView.swift
//  UI
//
//  Created by alvola on 26/08/2020.
//

import UIKit
import CoreFoundationLib

public final class GlobalSearchFaqsView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var faqsView: TripFaqsView!
    @IBOutlet public weak var separatorView: UIView!
    
    public weak var delegate: TripFaqsViewDelegate? {
        didSet {
            faqsView.delegate = delegate
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = UIFont.santander(size: 18.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withLocalizedString: localized("search_title_needHelp"))
        self.titleLabel.accessibilityIdentifier = "search_title_needHelp"
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.backgroundColor = .mediumSkyGray
        self.view?.backgroundColor = .white
    }
    
    public func addFaqs(with viewModels: [TripFaqViewModel]) {
        self.faqsView.setupVieModels(viewModels)
    }
    
    public func clearFAQs() {
        self.faqsView.removeSubviews()
        self.setNum(nil)
    }
    
    public var isEmpty: Bool {
        return faqsView.isEmpty
    }
    
    public func setBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
        self.faqsView.backgroundColor = color
        self.view?.backgroundColor = color
    }
    
    public func setNum(_ value: Int?) {
        titleLabel.attributedText = nil
        guard let value = value else { return titleLabel.configureText(withKey: "search_title_needHelp") }
        titleLabel.configureText(withLocalizedString: localized("search_title_needHelpNumber",
                                                        [StringPlaceholder(.number, "\(value)")]))
    }
}
