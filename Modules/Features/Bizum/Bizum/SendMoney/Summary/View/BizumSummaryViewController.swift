//
//  BizumSummaryViewController.swift
//  Bizum
//
//  Created by Jose C. Yebes on 13/10/2020.
//

import Operative
import UI
import ESUI

protocol BizumSummaryViewProtocol: OperativeSummaryViewProtocol {
    func setupBizumBody(_ viewModels: [BizumSummaryItem], actions: [OperativeSummaryStandardBodyActionViewModel], showLastSeparator: Bool, shareViewModel: ShareBizumSummaryViewModel?, whatsAppAction: (() -> Void)?)
    func hideShareByWhatsappView()
}

final class BizumSummaryViewController: OperativeSummaryViewController {
    private var action: (() -> Void)?
    private weak var body: OperativeSummaryBizumBodyView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
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

extension BizumSummaryViewController: BizumSummaryViewProtocol {
    func setupBizumBody(_ viewModels: [BizumSummaryItem], actions: [OperativeSummaryStandardBodyActionViewModel], showLastSeparator: Bool, shareViewModel: ShareBizumSummaryViewModel?, whatsAppAction: (() -> Void)?) {
        let body = OperativeSummaryBizumBodyView(frame: .zero)
        body.translatesAutoresizingMaskIntoConstraints = false
        body.setupWithItems(viewModels, actions: actions, showLastSeparator: showLastSeparator, shareViewModel: shareViewModel)
        body.delegate = self
        self.action = whatsAppAction
        self.body = body
        self.setupBody(body)
    }
    
    func hideShareByWhatsappView() {
        self.body?.hideShareByWhatsappView()
    }
}

extension BizumSummaryViewController: OperativeSummaryBizumBodyViewDelegate {
    func didCollapseRecipientsBody() {
        self.didCollapseBody()
    }
    
    func shareByWhatsappSelected() {
        self.action?()
    }
}
