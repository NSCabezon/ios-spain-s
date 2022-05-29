//
//  OptionsOnboardingStackView.swift
//  Onboarding
//
//  Created by José Hidalgo on 07/01/22.
//

import UIKit
import UI

class OptionsOnboardingStackView: UIStackView {
    let maxLanguagesPerLines = 3
    private var sections: [OnboardingStackSection] = []
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}

extension OptionsOnboardingStackView {
    
    func reloadSections(sections: [OnboardingStackSection],
                        distribution: UIStackView.Distribution = .fill,
                        spacing: CGFloat = 0) {
        for stackViewSection in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(stackViewSection)
            stackViewSection.removeFromSuperview()
        }
        for section in sections {
            insertSection(section: section, distribution: distribution, spacing: spacing)
        }
    }
    
    func insertSection(section: OnboardingStackSection,
                       index: Int? = nil,
                       distribution: UIStackView.Distribution = .fill,
                       spacing: CGFloat = 0) {
        let stackViewSection = UIStackView()
        stackViewSection.axis = .vertical
        stackViewSection.alignment = .fill
        stackViewSection.distribution = distribution
        stackViewSection.spacing = spacing
        stackViewSection.backgroundColor = stackView.backgroundColor
        for item in section.items {
            if let rowView = getViewForItem(item: item) {
                stackViewSection.addArrangedSubview(rowView)
                rowView.accessibilityIdentifier = item.accessibilityIdentifier ?? "" + "_\(index ?? 0)"
            }
        }
        if let index = index {
            for stackIndex in (index..<stackView.arrangedSubviews.count).reversed() {
                if let stackViewSection = getSection(identifier: stackIndex) {
                    stackViewSection.tag = stackIndex + 1
                }
            }
            stackViewSection.tag = index
            stackView.insertArrangedSubview(stackViewSection, at: index)
            sections.insert(section, at: index)
        } else {
            stackViewSection.tag = stackView.arrangedSubviews.count
            stackView.addArrangedSubview(stackViewSection)
            sections.append(section)
        }
    }
}

private extension OptionsOnboardingStackView {
    
    func getSection(identifier: Int) -> UIStackView? {
        return stackView.arrangedSubviews.first(where: {$0.tag == identifier}) as? UIStackView
    }
    
    func getViewForItem(item: OnboardingStackItemProtocol) -> UIView? {
        let listViews = UINib(nibName: item.reuseIdentifier, bundle: .module).instantiate(withOwner: nil, options: nil)
        guard let view = listViews.first as? OnboardingStackViewBase else {
            return nil
        }
        item.bind(view: view)
        return view
    }
}
