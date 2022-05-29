//
//  LogoutByeViewController.swift
//  RetailClean
//
//  Created by alvola on 03/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit

protocol LogoutByeViewControllerProtocol: class {
    func configureView(with: LogoutByeViewModel)
}

final class LogoutByeViewController: UIViewController {
    private var presenter: LogoutByePresenterProtocol?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private  weak var bottomLabel: UILabel!
    
    private var viewModel: LogoutByeViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else { return }
            drawView(with: viewModel)
        }
    }
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: LogoutByePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFonts()
        setAppearance()
        setAccessibilityIdentifiers()
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }
}

// MARK: - Private Methods

private extension LogoutByeViewController {
    
    func setFonts() {
        titleLabel.font = UIFont.santander(family: .headline, type: .bold, size: 30)
        subtitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 22)
        bottomLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
    }
    
    func setAppearance() {
        subtitleLabel.textColor = UIColor.lisboaGrayNew
        bottomLabel.textColor = UIColor.sanGreyDark
        [titleLabel, subtitleLabel, bottomLabel].forEach { $0.set(lineHeightMultiple: 0.75) }
    }
    
    func drawView(with viewModel: LogoutByeViewModelProtocol) {
        imageView.image = viewModel.image
        titleLabel.attributedText = viewModel.attributedTitle
        subtitleLabel.set(localizedStylableText: viewModel.subtitleText)
        bottomLabel.set(localizedStylableText: viewModel.activateText)
    }
    
    func setAccessibilityIdentifiers() {
        imageView.accessibilityIdentifier = "bye1"
        titleLabel.accessibilityIdentifier = "exit_title_thankYou"
        subtitleLabel.accessibilityIdentifier = "exit_text_quiet"
        bottomLabel.accessibilityIdentifier = "exit_text_activate"
    }
}

extension LogoutByeViewController: LogoutByeViewControllerProtocol {
    
    func configureView(with viewModel: LogoutByeViewModel) {
        self.viewModel = viewModel
    }
}
