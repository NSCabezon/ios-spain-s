//
//  OneProductMoreOptionsViewController.swift
//  UIOneComponents
//
//  Created by Iván Estévez Nieto on 25/4/22.
//

import UI
import CoreFoundationLib
import OpenCombine

public final class OneProductMoreOptionsViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var closeLabel: UILabel!
    @IBOutlet private weak var oneGradientView: OneGradientView!
    private let columns = 4
    private let viewModel: OneProductMoreOptionsViewModelProtocol
    private var subscriptions = Set<AnyCancellable>()
    
    public init(viewModel: OneProductMoreOptionsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: "OneProductMoreOptionsViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        viewModel.viewDidLoad()
    }
}

private extension OneProductMoreOptionsViewController {
    func setupView() {
        setupNavigationBar()
        setupGradientBackground()
    }
    
    func bind() {
        viewModel.elementsPublisher
            .sink { [weak self] elements in
            self?.addSections(elements)
        }.store(in: &subscriptions)
    }
    
    func setupNavigationBar() {
        titleLabel.text = localized("toolbar_title_moreOptions")
        titleLabel.accessibilityIdentifier = AccessibilitySavingsShortcuts.navigationBarTitle.rawValue
        titleLabel.textColor = .oneSantanderRed
        titleLabel.font = .santander(family: .headline, type: .bold, size: 16)
        closeImageView.image = Assets.image(named: "oneIcnClose")
        closeLabel.text = localized("generic_label_close")
        closeLabel.textColor = .oneLisboaGray
        closeLabel.font = .santander(family: .micro, type: .regular, size: 10)
    }
    
    func setupGradientBackground() {
        oneGradientView.setupType(.oneGrayGradient(direction: .bottomToTop))
    }
    
    @IBAction func closeView() {
        dismiss(animated: true)
    }
    
    func addSections(_ elements: [OneProductMoreOptionsAction]) {
        elements.forEach { element in
            let sectionStackView = createSection(element)
            self.stackView.addArrangedSubview(sectionStackView)
        }
        addBottomSpace()
    }
    
    func createSection(_ section: OneProductMoreOptionsAction) -> UIStackView {
        let sectionStackView = createSectionStackView()
        let sectionTitleLabel = UILabel()
        sectionTitleLabel.text = section.sectionTitle
        sectionTitleLabel.font = .santander(family: .headline, type: .bold, size: 15)
        sectionTitleLabel.textColor = .oneDarkGrey
        sectionTitleLabel.isHidden = section.sectionTitle.isEmpty
        sectionTitleLabel.accessibilityIdentifier = "\(AccessibilitySavingsShortcuts.titleLabel)\(section.accessibilitySuffix ?? "")"
        sectionStackView.addArrangedSubview(sectionTitleLabel)
        let buttonsStackViews = createButtonsStackViews(section.elements)
        buttonsStackViews.forEach { sectionStackView.addArrangedSubview($0) }
        return sectionStackView
    }
    
    func createButton(_ actionInfo: OneProductMoreOptionsActionElement) -> OneShortcutButton {
        let button = OneShortcutButton()
        let configuration = OneShortcutButtonConfiguration(title: actionInfo.title,
                                                           icon: actionInfo.iconName,
                                                           backgroundColor: .oneWhite,
                                                           backgroundImage: nil,
                                                           offerImage: nil,
                                                           tagTitle: nil,
                                                           accessibilitySuffix: actionInfo.accessibilitySuffix,
                                                           isDisabled: actionInfo.isDisabled,
                                                           action: actionInfo.action)
        button.setViewModel(configuration: configuration, hasHorizontalStyle: false)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 73).isActive = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return button
    }
    
    func createSectionStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }
    
    func createButtonsStackViews(_ elements: [OneProductMoreOptionsActionElement]) -> [UIStackView] {
        var stackViews = [UIStackView]()
        var lastStackView: UIStackView?
        for (index, element) in elements.enumerated() {
            if index.isMultiple(of: columns) {
                if let lastStackView = lastStackView {
                    fillStackView(lastStackView)
                    stackViews.append(lastStackView)
                }
                lastStackView = createButtonsLineStackView()
                let button = createButton(element)
                lastStackView?.addArrangedSubview(button)
            } else {
                let button = createButton(element)
                lastStackView?.addArrangedSubview(button)
            }
        }
        if let lastStackView = lastStackView {
            fillStackView(lastStackView)
            stackViews.append(lastStackView)
        }
        return stackViews
    }
    
    func createButtonsLineStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }
    
    func fillStackView(_ stackView: UIStackView) {
        stackView.addArrangedSubview(UIView())
    }
    
    func addBottomSpace() {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        stackView.addArrangedSubview(view)
    }
}
