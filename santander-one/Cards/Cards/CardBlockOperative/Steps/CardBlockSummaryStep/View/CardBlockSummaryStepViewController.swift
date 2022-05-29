//
//  CardBlockSummaryStepViewController.swift
//  Cards
//
//  Created by Laura González on 31/05/2021.
//

import Foundation
import CoreFoundationLib
import Operative
import UI

public protocol CardBlockSummaryStepViewProtocol: OperativeSummaryViewProtocol { }

final class CardBlockSummaryStepViewController: OperativeSummaryViewController {
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
        builder.build(on: self, with: nil)
    }
}

extension CardBlockSummaryStepViewController: CardBlockSummaryStepViewProtocol {}
