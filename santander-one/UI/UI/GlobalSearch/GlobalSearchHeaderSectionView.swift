//
//  GlobalSearchHeaderSectionView.swift
//  UI
//
//  Created by alvola on 26/08/2020.
//

import UIKit
import CoreFoundationLib

public final class GlobalSearchHeaderSectionView: UIView {
    
    private let headerView = UIView()
    private var headerTitle: LocalizedStylableText
    
    public var titleTopSpace: CGFloat = 9.0 {
        didSet {
            topConstraint?.constant = titleTopSpace
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.santander(size: 18.0)
        label.textColor = UIColor.lisboaGray
        label.configureText(withLocalizedString: headerTitle)
        label.textAlignment = .left
        headerView.addSubview(label)
        return label
    }()
    
    private var topConstraint: NSLayoutConstraint?
    
    public init(headerTitle: LocalizedStylableText) {
        self.headerTitle = headerTitle
        super.init(frame: .zero)
        setupView()
    }
    
    public func setTitle(_ title: LocalizedStylableText) {
        label.attributedText = nil
        label.configureText(withLocalizedString: title)
    }
    
    public func setTitleColor(_ color: UIColor) {
        label.textColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.fullFit()
        headerView.backgroundColor = UIColor.clear
        applyConstraints(to: label)
    }
    
    private func applyConstraints(to label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: titleTopSpace)
        topConstraint?.isActive = true
        label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 18.0).isActive = true
        headerView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 18.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
    }
}
