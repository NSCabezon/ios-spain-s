//
//  OperabilityChangeSummaryViewController.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

import UIKit
import Operative
import UI
import CoreFoundationLib

protocol OperabilityChangeSummaryViewProtocol: OperativeView {
    func setOperabilityText(_ text: String)
    func addFooterItems(_ viewModels: [SummaryFooterItemViewModel])
}

extension OperabilityChangeSummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

class OperabilityChangeSummaryViewController: UIViewController {

    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var footerTitleLabel: UILabel!
    @IBOutlet private weak var footerStackView: UIStackView!
    @IBOutlet private weak var okImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var operabilityLevelLabel: UILabel!
    
    var presenter: OperabilityChangeSummaryPresenterProtocol

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: OperabilityChangeSummaryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        setupNavigationBar()
        presenter.viewDidLoad()
    }
}

extension OperabilityChangeSummaryViewController: OperabilityChangeSummaryViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func setOperabilityText(_ text: String) {
        operabilityLevelLabel.text = localized(text)
    }
    
    func addFooterItems(_ viewModels: [SummaryFooterItemViewModel]) {
        viewModels.forEach {
            let item = SummaryFooterItem($0)
            self.footerStackView.addArrangedSubview(item)
            self.addSeparator(stackView: footerStackView)
        }
        // Add safe area extra bottom view
        if #available(iOS 11.0, *), let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            let extraView = UIView(frame: .zero)
            extraView.backgroundColor = .blueAnthracita
            extraView.heightAnchor.constraint(equalToConstant: bottomPadding).isActive = true
            footerStackView.addArrangedSubview(extraView)
        }
    }
}

private extension OperabilityChangeSummaryViewController {
    
    func commonInit() {
        configureViews()
        configureFooter()
        configureLabels()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "genericToolbar_title_summary")
        )
        builder.build(on: self, with: nil)
        let rightBarButton = UIBarButtonItem(image: Assets.image(named: "icnClose")?.withRenderingMode(.alwaysTemplate),
                                            style: .plain,
                                            target: self,
                                            action: #selector(finishOperative))
        rightBarButton.tintColor = .santanderRed
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func configureViews() {
        self.view.backgroundColor = UIColor.skyGray
        okImageView.image = Assets.image(named: "icnOkSummary")
    }
    
    func configureFooter() {
        footerView.backgroundColor = UIColor.blueAnthracita
        footerTitleLabel.text = localized("summary_label_nowThat")
        addSeparator(stackView: footerStackView)
    }
    
    func configureLabels() {
        titleLabel.text = localized("summe_title_perfect")
        titleLabel.font = .santander(family: .headline, type: .bold, size: 28)
        titleLabel.textColor = .lisboaGray

        subtitleLabel.text = localized("summary_text_level")
        subtitleLabel.font = .santander(family: .headline, type: .regular, size: 16)
        subtitleLabel.textColor = .lisboaGray
        
        operabilityLevelLabel.textColor = .lisboaGray
        operabilityLevelLabel.font = .santander(family: .headline, type: .bold, size: 16)
    }
    
    func addFooterItemSeparator() {
        self.addSeparator(stackView: footerStackView)
    }
        
    func addFooterItem(_ item: SummaryFooterItem) {
        self.footerStackView.addArrangedSubview(item)
    }
    
    func addSeparator(stackView: UIStackView) {
        let viewSeparator = PointLine(frame: .zero)
        viewSeparator.pointColor = UIColor.mediumSkyGray
        stackView.addArrangedSubview(viewSeparator)
        let heightConstraint = NSLayoutConstraint(
            item: viewSeparator,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 1)
        self.view.addConstraint(heightConstraint)
    }
    
    @objc func finishOperative() {
        presenter.finishOperativeSelected()
    }
}
