//
//  BizumRefundMoneySummaryViewController.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 11/12/20.
//

import Operative
import UI
import ESUI

final class BizumRefundMoneySummaryViewController: OperativeSummaryViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func setupNavigationBar() {
        let titleImage = TitleImage(
            image: ESAssets.image(named: "icnBizumHeader"),
            topMargin: 4,
            width: 16,
            height: 16
        )
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithImage(key: "genericToolbar_title_summary",
                                   image: titleImage)
        )
        builder.build(on: self, with: nil)
    }
}

extension BizumRefundMoneySummaryViewController: BizumSummaryViewProtocol {
    func shareByImage(_ shareView: UIShareView, container: UIView, onlyWhatsApp: Bool) {}
    
    func setupBizumBody(_ viewModels: [BizumSummaryItem],
                        actions: [OperativeSummaryStandardBodyActionViewModel],
                        showLastSeparator: Bool,
                        shareViewModel: ShareBizumSummaryViewModel?,
                        whatsAppAction: (() -> Void)?) {
        let body = OperativeSummaryBizumBodyView(frame: .zero)
        body.translatesAutoresizingMaskIntoConstraints = false
        body.setupWithItems(viewModels, actions: actions, showLastSeparator: showLastSeparator)
        self.setupBody(body)
    }
    
    func hideShareByWhatsappView() { }
}
