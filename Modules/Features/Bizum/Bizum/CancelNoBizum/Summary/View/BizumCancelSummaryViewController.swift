import Operative
import UI
import ESUI

final class BizumCancelSummaryViewController: OperativeSummaryViewController {
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
