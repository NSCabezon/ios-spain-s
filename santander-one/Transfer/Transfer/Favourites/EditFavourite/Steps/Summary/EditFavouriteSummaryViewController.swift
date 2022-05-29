//
//  EditFavouriteSummaryViewController.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 12/08/2021.
//

import Operative
import UI
import CoreFoundationLib

final class EditFavouriteSummaryViewController: OperativeSummaryViewController {
    private let presenter: EditFavouriteSummaryPresenterProtocol
    private var navigationBarTitle: String? {
        didSet {
            self.setupNavigationBar()
        }
    }
    
    init(presenter: EditFavouriteSummaryPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky, title: .title(key: self.navigationBarTitle ?? "genericToolbar_title_summary"))
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
}

private extension EditFavouriteSummaryViewController {
    @objc func close() {
        self.presenter.close()
    }
}
