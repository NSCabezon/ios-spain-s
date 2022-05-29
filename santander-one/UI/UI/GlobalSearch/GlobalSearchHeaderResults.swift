//
//  GlobalSearchHeaderResults.swift
//  UI
//
//  Created by alvola on 25/08/2020.
//

import UIKit
import CoreFoundationLib

public final class GlobalSearchHeaderResults: UIView {
    
    let globalSearchHeaderResultsHeight: CGFloat = 109.0
    public var globalSearchHeaderResultsCollapsedHeight: CGFloat = 48.0
    public var titleTopDistance: CGFloat = 18.0 {
        didSet {
            titleTopConstraint.constant = titleTopDistance
        }
    }
    
    private lazy var titleTopConstraint: NSLayoutConstraint = {
        return titleLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor, constant: titleTopDistance)
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lisboaGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "globalSearch_text_result"
        addSubview(label)
        return label
    }()
    
    private lazy var betweenSeparatorView: UIView = {
        separatorConstructor()
    }()
    
    private lazy var topSeparatorView: UIView = {
        separatorConstructor()
    }()
    
    private lazy var bottomSeparatorView: UIView = {
        separatorConstructor()
    }()
    
    private lazy var segmentedControlView: LisboaSegmentedControl = {
        let segmented = LisboaSegmentedControl(frame: .zero)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.setup(with: currentSegments.map { $0.sectionTitle },
                        accessibilityIdentifiers: currentSegments.map { $0.sectionTitle })
        segmented.backgroundColor = .skyGray
        segmented.layer.cornerRadius = 5.0
        addSubview(segmented)
        segmented.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        segmented.accessibilityIdentifier = "globalSearchSegmentedKindOfResult"
        return segmented
    }()
    
    private lazy var currentHeightConstraint: NSLayoutConstraint = {
        return heightAnchor.constraint(equalToConstant: globalSearchHeaderResultsHeight)
    }()
    
    private var currentSegments = [GlobalSearchFilterType.all,
                                   GlobalSearchFilterType.movement,
                                   GlobalSearchFilterType.action,
                                   GlobalSearchFilterType.help] {
        didSet {
            let segmentTitles = currentSegments.map { $0.sectionTitle }
            segmentedControlView.setup(with: segmentTitles,
                                       accessibilityIdentifiers: segmentTitles)
        }
    }
    
    public var filterAction: ((GlobalSearchFilterType) -> Void)?
    
    public var withoutSegmented: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func hideTopSeparator(_ hide: Bool) {
        topSeparatorView.isHidden = hide
    }
    
    public func setResults(_ results: Int) {
        setNumResults(results)
        hideSegmentedControl(withoutSegmented || results == 0)
    }
    
    public func setSegments(_ segments: [GlobalSearchFilterType]) {
        currentSegments = segments
        hideSegmentedControl(withoutSegmented || segments.count < 2)
    }
    
    public func setTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        currentHeightConstraint.isActive = true
        backgroundColor = .white
        configureLabel()
        configureSegmentedView()
        configureSeparatorViews()
    }
    
    private func configureLabel() {
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 17.0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        titleTopConstraint.isActive = true
    }
    
    private func configureSegmentedView() {
        segmentedControlView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14.0).isActive = true
        self.trailingAnchor.constraint(equalTo: segmentedControlView.trailingAnchor, constant: 14.0).isActive = true
        segmentedControlView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        segmentedControlView.topAnchor.constraint(equalTo: betweenSeparatorView.bottomAnchor, constant: 10.0).isActive = true
    }
    
    private func configureSeparatorViews() {
        topSeparatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        self.trailingAnchor.constraint(equalTo: self.topSeparatorView.trailingAnchor, constant: 0.0).isActive = true
        topSeparatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        
        betweenSeparatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        self.trailingAnchor.constraint(equalTo: self.betweenSeparatorView.trailingAnchor, constant: 0.0).isActive = true
        betweenSeparatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        betweenSeparatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0).isActive = true
        
        bottomSeparatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        self.trailingAnchor.constraint(equalTo: self.bottomSeparatorView.trailingAnchor, constant: 0.0).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        self.bottomAnchor.constraint(equalTo: self.bottomSeparatorView.bottomAnchor, constant: 0.0).isActive = true
    }
    
    private func setNumResults(_ num: Int) {
        let key = num == 1 ? "globalSearch_text_result_one" : "globalSearch_text_result_other"
        titleLabel.font = UIFont.santander(family: .text, size: 17.0)
        titleLabel.configureText(withLocalizedString: localized(key, [StringPlaceholder(.number, String(num))]))
    }
    
    private func hideSegmentedControl(_ hide: Bool) {
        segmentedControlView.isHidden = hide
        bottomSeparatorView.isHidden = hide
        currentHeightConstraint.constant = hide ? globalSearchHeaderResultsCollapsedHeight : globalSearchHeaderResultsHeight
    }
    
    private func separatorConstructor() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.mediumSkyGray
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    @objc private func valueChanged() {
        let index = self.segmentedControlView.selectedSegmentIndex
        guard index < currentSegments.count else { return }
        filterAction?(currentSegments[index])
    }
}
