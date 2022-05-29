//
//  DeleteScheduledTransferResumeStepViewcontroller.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 20/7/21.
//

import Operative
import UI
import CoreFoundationLib

protocol DeleteScheduledTransferResumeStepViewProtocol: OperativeView { }

final class DeleteScheduledTransferResumeViewcontroller: OperativeSummaryViewController {
    let presenter: DeleteScheduledTransferResumeStepPresenterProtocol?
    
    init(presenter: DeleteScheduledTransferResumeStepPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
    }
    
    override func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky,
                                           title: .title(key: "genericToolbar_title_summary"))
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
}

private extension DeleteScheduledTransferResumeViewcontroller {
    @objc func close() {
        self.presenter?.close()
    }
}
