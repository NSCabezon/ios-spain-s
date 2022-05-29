//
//  CardOnOffSummaryStepViewController.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 30/8/21.
//

import Foundation
import CoreFoundationLib
import Operative
import UI

public protocol CardOnOffSummaryStepViewProtocol: OperativeSummaryViewProtocol { }

final class CardOnOffSummaryStepViewController: OperativeSummaryViewController {
    let presenter: CardOnOffSummaryStepPresenterProtocol?

    init(presenter: CardOnOffSummaryStepPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func setupNavigationBar() {
        let titleImage = TitleImage(image: nil,
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithImage(key: "genericToolbar_title_summary",
                                   image: titleImage)
        )
        builder.setRightActions(.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
}

extension CardOnOffSummaryStepViewController: CardOnOffSummaryStepViewProtocol {}

private extension CardOnOffSummaryStepViewController {
    @objc func close() {
        self.presenter?.close()
    }
}
