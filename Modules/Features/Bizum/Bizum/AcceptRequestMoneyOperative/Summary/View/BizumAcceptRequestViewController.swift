//
//  BizumAcceptRequestViewController.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 03/12/2020.
//

import Operative
import UI
import ESUI

final class BizumAcceptRequestViewController: OperativeSummaryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    override func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
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

extension BizumAcceptRequestViewController: BizumSummaryViewProtocol {
    func setupBizumBody(_ viewModels: [BizumSummaryItem], actions: [OperativeSummaryStandardBodyActionViewModel], showLastSeparator: Bool, shareViewModel: ShareBizumSummaryViewModel?, whatsAppAction: (() -> Void)?) {
        let body = OperativeSummaryBizumBodyView(frame: .zero)
        body.translatesAutoresizingMaskIntoConstraints = false
        body.setupWithItems(viewModels, actions: actions, showLastSeparator: showLastSeparator)
        self.setupBody(body)
    }
    
    func hideShareByWhatsappView() { }
}
