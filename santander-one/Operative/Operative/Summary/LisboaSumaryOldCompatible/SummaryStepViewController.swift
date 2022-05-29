import UIKit
import UI
import CoreFoundationLib

public struct HeaderInfoSummaryModel {
    let title: String
    let info: String
    
    public init(title: String, info: String) {
        self.title = title
        self.info = info
    }
}

public struct FooterInfoSummaryModel {
    let title: String
    let image: String
    let action: (() -> Void)?
    
    public init(title: String, image: String, action: (() -> Void)?) {
        self.title = title
        self.image = image
        self.action = action
    }
}

public final class SummaryStepViewController: UIViewController {
    @IBOutlet weak var okImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var footerTitleLabel: UILabel!
    @IBOutlet weak var headerStackview: UIStackView!
    @IBOutlet weak var footerStackview: UIStackView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var viewScrollView: UIView!
    
    public init() {
        super.init(nibName: "SummaryStepViewController", bundle: .module)
        self.title = localized("genericToolbar_title_summary")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.skyGray
        viewScrollView.backgroundColor = .skyGray
        okImageView.image = Assets.image(named: "icnOkSummary")
        titleLabel.font = UIFont.santander(family: .headline, type: .bold, size: 28)
        titleLabel.textColor = UIColor(red: 84.0 / 255.0, green: 84.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
        titleLabel.text = localized("summe_title_perfect")
        subtitleLabel.font = UIFont.santander(family: .headline, type: .regular, size: 16)
        subtitleLabel.textColor = UIColor(red: 84.0 / 255.0, green: 84.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
        footerTitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 20)
        footerTitleLabel.textColor = UIColor.white
        footerTitleLabel.text = localized("summary_label_nowThat")
        headerView.backgroundColor = UIColor.white
        headerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        headerView.layer.borderWidth = 1
        footerView.backgroundColor = UIColor.blueAnthracita
        scrollview.backgroundColor = .skyGray
        scrollview.delegate = self
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPopGestureEnabled(false)
    }

    public final func configureView(title: String, header: [HeaderInfoSummaryModel], footer: [FooterInfoSummaryModel]) {
        subtitleLabel.text = localized(title)
        configureHeaderItems(header)
        configureFooterItems(footer)
    }
}

private extension SummaryStepViewController {
    private func configureHeaderItems(_ items: [HeaderInfoSummaryModel]) {
        guard !items.isEmpty else {
            headerView.isHidden = true
            return
        }
        for index in 0..<items.count {
            let item = items[index]
            addHeaderItem(stackView: headerStackview, title: localized(item.title), subtitle: item.info)
            if index < items.count - 1 {
                addSeparator(stackView: headerStackview)
            }
        }
    }
    
    private func configureFooterItems(_ items: [FooterInfoSummaryModel]) {
        guard !items.isEmpty else {
            footerView.isHidden = true
            return
        }
        addSeparator(stackView: footerStackview)
        for item in items {
            addFooterItem(stackView: footerStackview, title: localized(item.title), image: Assets.image(named: item.image), action: item.action)
            addSeparator(stackView: footerStackview)
        }
    }
    
    private func addHeaderItem(stackView: UIStackView, title: String, subtitle: String) {
        guard let bundle = Bundle(for: OperativeContainer.self).url(forResource: "Operative", withExtension: "bundle").flatMap(Bundle.init) else {
            return
        }
        guard let view = bundle.loadNibNamed("SummaryHeaderItemView", owner: nil, options: nil)?.first as? SummaryHeaderItemView else {
            return
        }
        view.titleLabel.text = title
        view.subtitleLabel.text = subtitle
        stackView.addArrangedSubview(view)
    }
    
    private func addFooterItem(stackView: UIStackView, title: String, image: UIImage?, action: (() -> Void)?) {
        guard let bundle = Bundle(for: OperativeContainer.self).url(forResource: "Operative", withExtension: "bundle").flatMap(Bundle.init) else {
            return
        }
        guard let view = bundle.loadNibNamed("SummaryFooterItemView", owner: nil, options: nil)?.first as? SummaryFooterItemView else {
            return
        }
        view.action = action
        view.titleLabel.text = title
        view.titleImageview.image = image
        stackView.addArrangedSubview(view)
    }
    
    private func addSeparator(stackView: UIStackView) {
        let viewSperator = UIView()
        viewSperator.backgroundColor = UIColor.mediumSkyGray
        stackView.addArrangedSubview(viewSperator)
        let heightConstraint = NSLayoutConstraint(item: viewSperator, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 1)
        view.addConstraint(heightConstraint)
    }
}

extension SummaryStepViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !footerStackview.arrangedSubviews.isEmpty else { return }
        if scrollView.contentOffset.y >= 0 {
            scrollview.backgroundColor = .blueAnthracita
        } else {
            scrollview.backgroundColor = .skyGray
        }
    }
}
