//
//  MenuView.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 02/09/2019.
//

import UIKit

class MenuView: UIView {
    
    // MARK: - Private
    
    @IBOutlet var container: UIView!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var menuButton: GlobileButton!
    @IBOutlet private weak var bottomMenuMargin: NSLayoutConstraint!
    private var settings: Settings = .default()
    private lazy var menuItemsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    private let menuContainerViewMargin: CGFloat = 20
    private var bottomMenuCloseMarginConstant: CGFloat {
        if #available(iOS 11.0, *), let safeAreaBottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            return -(menuContainerView.frame.size.height + menuContainerViewMargin + safeAreaBottomInset)
        } else {
            return -(menuContainerView.frame.size.height + menuContainerViewMargin)
        }
    }
    private lazy var menuContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Public
    
    struct Settings {
        
        let columns: Int
        
        static func `default`() -> Settings {
            return Settings(columns: 3)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        menuContainerView.layer.cornerRadius = 5.0
    }
    
    func setup(_ settings: Settings) {
        self.settings = settings
    }
    
    func set(_ items: [MenuItem]) {
        var currentStackView = UIStackView()
        items.enumerated().forEach { index, item in
            defer {
                // Add fake views if we are in the last index
                let fakeViewsNeeded = settings.columns - currentStackView.arrangedSubviews.count
                if index == items.indices.last && fakeViewsNeeded > 0 {
                    for _ in 0 ..< fakeViewsNeeded {
                        currentStackView.addArrangedSubview(fakeView())
                    }
                }
            }
            defer {
                // Add button with separator
                let needsSeparator = index % settings.columns != settings.columns - 1 && index != items.indices.last
                currentStackView.addArrangedSubview(button(for: item, showingSeparator: needsSeparator))
            }
            guard index % settings.columns == 0 else { return }
            currentStackView = addRow(showingSeparator: (items.count - (index + 1)) >= settings.columns)
        }
        layoutIfNeeded()
        layoutSubviews()
        menuButton.isSelected = false
        bottomMenuMargin.constant = bottomMenuCloseMarginConstant
        container.isHidden = false
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return container.subviews.contains(where: { !$0.isHidden && $0.point(inside: container.convert(point, to: $0), with: event) })
    }
}

// MARK: - Private

private extension MenuView {
    
    func setupMenuButton() {
        menuButton.layer.cornerRadius = menuButton.frame.size.height / 2
        menuButton.backgroundColor = .sanRed
        menuButton.tintColor = .white
        menuButton.setImage(UIImage(fromModuleWithName: "icCloseMenu")?.withRenderingMode(.alwaysTemplate), for: .selected)
        menuButton.setImage(UIImage(fromModuleWithName: "icOpenMenu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuButton.onClick(menuButtonSelected)
        menuButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        menuButton.layer.shadowOpacity = 0.57
        menuButton.layer.shadowColor = UIColor.black.cgColor
        menuButton.layer.shadowRadius = 6
    }
    
    func setup() {
        Bundle.module?.loadNibNamed(String(describing: MenuView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        container.isHidden = true
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubviewWithAutoLayout(
            menuContainerView,
            topAnchorConstant: .equal(to: menuContainerViewMargin),
            bottomAnchorConstant: .equal(to: -menuContainerViewMargin),
            leftAnchorConstant: .equal(to: menuContainerViewMargin),
            rightAnchorConstant: .equal(to: -menuContainerViewMargin)
        )
        setupMenuButton()
        stackView.addArrangedSubview(view)
        menuContainerView.addSubviewWithAutoLayout(
            menuItemsStackView,
            topAnchorConstant: .equal(to: 15),
            bottomAnchorConstant: .equal(to: -15)
        )
        backgroundView.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        backgroundView.isHidden = true
    }
    
    func addRow(showingSeparator separator: Bool = false) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        defer {
            menuItemsStackView.addArrangedSubview(stackView)
            if separator {
                let separatorContainerView = UIView()
                let separatorView = UIView()
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                separatorView.backgroundColor = .paleSkyBlue
                separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                separatorContainerView.addSubviewWithAutoLayout(
                    separatorView,
                    leftAnchorConstant: .equal(to: 30),
                    rightAnchorConstant: .equal(to: -30)
                )
                menuItemsStackView.addArrangedSubview(separatorContainerView)
            }
        }
        return stackView
    }
    
    func fakeView() -> UIView {
        let view = UIView()
        return view
    }
    
    func button(for item: MenuItem, showingSeparator separator: Bool = false) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let button = GlobileButton(type: .custom)
        button.setImage(UIImage(fromModuleWithName: item.logo)?.withRenderingMode(.alwaysTemplate), position: .top)
        button.setTitle(item.title, for: .normal)
        button.setTitleColor(.greyishBrown, for: .normal)
        button.titleLabel?.font = .santanderText(with: 14)
        button.tintColor = .lightGreyBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 65).isActive = true
        button.onClick {
            self.hideMenuBackground()
            item.action()
        }
        stackView.addArrangedSubview(button)
        if separator {
            let separatorContainerView = UIView()
            let separatorView = UIView()
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .paleSkyBlue
            separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
            separatorContainerView.addSubviewWithAutoLayout(
                separatorView,
                topAnchorConstant: .equal(to: 12),
                bottomAnchorConstant: .equal(to: -12)
            )
            stackView.addArrangedSubview(separatorContainerView)
        }
        return stackView
    }
    
    func menuButtonSelected() {
        menuButton.isSelected = !menuButton.isSelected
        bottomMenuMargin.constant = menuButton.isSelected ? 0 : bottomMenuCloseMarginConstant
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.layoutIfNeeded()
                guard self.menuButton.isSelected else {
                    self.backgroundView.alpha = 0.0
                    return
                }
                self.backgroundView.isHidden = false
                self.backgroundView.alpha = 1.0
            },
            completion: { finished in
                guard finished && !self.menuButton.isSelected else { return }
                self.backgroundView.isHidden = true
            }
        )
    }
    
    func hideMenuBackground() {
        menuButton.isSelected = false
        bottomMenuMargin.constant = bottomMenuCloseMarginConstant
        self.backgroundView.isHidden = true
        self.backgroundView.alpha = 0.0
    }
}
