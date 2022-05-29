//
//  NeedHelpForView.swift
//  UI
//
//  Created by alvola on 26/08/2020.
//

import UIKit
import CoreFoundationLib

public final class NeedHelpForView: UIView {
    
    public let titleHeight: CGFloat
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lisboaGray
        label.font = UIFont.santander(type: .regular, size: 17.0)
        label.configureText(withKey: "search_title_needHelp")
        
        addSubview(label)
        return label
    }()
    
    private lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .mediumSkyGray
        addSubview(view)
        return view
    }()
    
    public init(topSpace: CGFloat) {
        self.titleHeight = topSpace
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setNum(_ value: Int?) {
        label.attributedText = nil
        guard let value = value else { return label.configureText(withKey: "search_title_needHelp") }
        label.configureText(withLocalizedString: localized("search_title_help", [StringPlaceholder(.number, "\(value)")]))
    }
    
    public func hideSeparator(_ hide: Bool) {
        bottomSeparatorView.backgroundColor = hide ? .clear : .mediumSkyGray
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        label.frame.origin = CGPoint(x: 17.0, y: 11.0)
        label.frame.size = CGSize(width: rect.width, height: 29.0)
        bottomSeparatorView.frame = CGRect(x: 0.0, y: titleHeight, width: rect.width, height: 1.0)
    }
    
    private func configureView() {
        self.backgroundColor = .white
    }
}
