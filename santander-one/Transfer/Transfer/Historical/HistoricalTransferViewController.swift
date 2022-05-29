//
//  HistoricalEmittedViewController.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 01/04/2020.
//

import CoreFoundationLib
import UI
import Operative

protocol HistoricalTransferViewProtocol: UIViewController {
    func showLoadingView()
    func setAllTransfers(_ transfers: [EmittedGroupViewModel])
    func setReceivedTransfers(_ transfers: [EmittedGroupViewModel])
    func setEmittedTransfers(_ transfers: [EmittedGroupViewModel])
    func setSearchedText(_ text: String, resultsNum: Int)
    func setEmptySearchedText(_ text: String)
    func showComingSoon()
}

final class HistoricalTransferViewController: UIViewController {
    @IBOutlet private weak var segmentedControlView: SegmentedControlView!
    @IBOutlet private weak var textField: LisboaTextfield!
    @IBOutlet private weak var scrollableView: UIView!
    
    private var scrollableStackView = HorizontalScrollableStackView(frame: .zero)
    private let presenter: HistoricalTransferPresenterProtocol
    
    private var visibleView: HistoricalTransferListView {
        let idx = self.segmentedControlView.getSelectedSegmentIndex()
        return idx == 0 ? self.allTransfersView :
            (idx == 1) ? self.issuedTransfersView :
            self.receivedTransfersView
    }
    
    private var allViews: [HistoricalTransferListView] {
        return [allTransfersView, issuedTransfersView, receivedTransfersView]
    }
    
    private lazy var allTransfersView: HistoricalTransferListView = {
        let view = HistoricalTransferListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var issuedTransfersView: HistoricalTransferListView = {
        let view = HistoricalTransferListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var receivedTransfersView: HistoricalTransferListView = {
        let view = HistoricalTransferListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(presenter: HistoricalTransferPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "HistoricalTransferViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.textField.endEditing(true)
    }
}

private extension HistoricalTransferViewController {
    func commonInit() {
        self.configureScrollView()
        self.configureSegment()
        self.configureTextField()
        self.configureEmptyViews()
        self.configureAccessibilities()
    }
    
    func configureNavigationBar() {
        NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_historyTransfer")
        ).setLeftAction(.back(action: #selector(self.dismissSelected)))
        .setRightActions(.menu(action: #selector(self.menuSelected)))
        .build(on: self, with: self.presenter)
    }
    
    func configureSegment() {
        self.segmentedControlView.setSegmentKeys(
            [
                "search_tab_all", "search_tab_delivered", "search_tab_received"
            ],
            accessibilityIdentifiers: [
                AccessibilityTransferHistorical.btnAll,
                AccessibilityTransferHistorical.btnScheduled,
                AccessibilityTransferHistorical.btnReceived
            ]
        )
        self.segmentedControlView.delegate = self
        self.segmentedControlView.lisboaSegmentedControl.backgroundColor = .skyGray
        self.segmentedControlView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferViewSegmentedField
    }
    
    func configureTextField() {
        var textfiledStyle: LisboaTextFieldStyle {
            var lisboaTextFieldStyle = LisboaTextFieldStyle.default
            lisboaTextFieldStyle.fieldFont = UIFont.santander(size: 16)
            lisboaTextFieldStyle.fieldTextColor = .lisboaGray
            lisboaTextFieldStyle.containerViewBorderColor = UIColor.lightSky.cgColor
            lisboaTextFieldStyle.verticalSeparatorBackgroundColor = UIColor.darkTurqLight
            lisboaTextFieldStyle.extraInfoHorizontalSeparatorBackgroundColor = UIColor.clear
            return lisboaTextFieldStyle
        }
        self.textField.configure(with: nil,
                                 title: localized("search_hint_textConcept"),
                                 style: textfiledStyle,
                                 extraInfo: nil,
                                 disabledActions: TextFieldActions.usuallyDisabledActions,
                                 imageAccessibilityIdentifier: "imgCloseTextField")
        self.textField.field.addTarget(
            self,
            action: #selector(self.textFieldDidChange),
            for: UIControl.Event.editingChanged
        )
        self.textField.field.autocapitalizationType = .none
        self.textField.field.autocorrectionType = .no
        self.textField.field.returnKeyType = .done
        self.textField.setAllowOnlyCharacters(CharacterSet.search)
        self.textField.isHidden = true
        self.textField.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferViewSearchTextField
        self.textField.setAccessibleIdentifiers(titleLabelIdentifier: "titleTextField", fieldIdentifier: "fieldTextField", imageIdentifier: "imageTextField")
    }
    
    func configureScrollView() {
        self.scrollableView.backgroundColor = .skyGray
        self.scrollableStackView.setup(with: self.scrollableView)
        self.scrollableStackView.setScrollDelegate(self)
        self.scrollableStackView.enableScrollPagging(true)
        self.scrollableStackView.addArrangedSubview(self.allTransfersView)
        self.scrollableStackView.addArrangedSubview(self.issuedTransfersView)
        self.scrollableStackView.addArrangedSubview(self.receivedTransfersView)
        self.allTransfersView.widthAnchor.constraint(equalTo: self.scrollableView.widthAnchor).isActive = true
        self.allTransfersView.heightAnchor.constraint(equalTo: self.scrollableView.heightAnchor).isActive = true
        self.issuedTransfersView.widthAnchor.constraint(equalTo: self.scrollableView.widthAnchor).isActive = true
        self.issuedTransfersView.heightAnchor.constraint(equalTo: self.scrollableView.heightAnchor).isActive = true
        self.receivedTransfersView.widthAnchor.constraint(equalTo: self.scrollableView.widthAnchor).isActive = true
        self.receivedTransfersView.heightAnchor.constraint(equalTo: self.scrollableView.heightAnchor).isActive = true
        self.scrollableStackView.layoutIfNeeded()
        self.allViews.forEach { $0.setDelegate(self) }
    }
    
    func configureEmptyViews() {
        self.allTransfersView.configureEmptyTitle("transfer_title_emptyView_recent", subtitle: "transfer_text_emptyView_notDone")
        self.issuedTransfersView.configureEmptyTitle("transfer_title_emptyView_recent", subtitle: "transfer_text_emptyView_recent")
        self.receivedTransfersView.configureEmptyTitle("transfer_title_emptyView_recent", subtitle: "transfer_text_emptyView_notReceived")
    }
    
    @objc func menuSelected() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
    
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollableView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollableStackView.scrollRectToVisible(frame)
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        self.updateClearButtonIcon()
        guard let text = sender.text else { return }
        self.presenter.didSearchText(text,
                                     inTable: self.segmentedControlView.getSelectedSegmentIndex())
    }
    
    @objc func clearTextField() {
        self.textField.updateData(text: "")
        self.updateClearButtonIcon()
        self.presenter.clearSearch()
        self.textField.endEditing(true)
        self.allViews.forEach { $0.clearTableHeader() }
        self.configureEmptyViews()
    }
    
    func updateClearButtonIcon() {
        guard let text = self.textField.field.text, !text.isEmpty else { return self.textField.configure(extraInfo: nil) }
        self.textField.configure(
            extraInfo: (
                Assets.image(named: "clearField"),
                action: self.clearTextField
            )
        )
    }
    
    func scrollToTop() {
        self.allViews.forEach { $0.scrollToTop() }
    }
}

extension HistoricalTransferViewController: HistoricalTransferViewProtocol {
    func showLoadingView() {
        self.allViews.forEach { $0.startAnimating() }
    }
    
    func setAllTransfers(_ transfers: [EmittedGroupViewModel]) {
        self.textField.isHidden = false
        self.allTransfersView.addResults(transfers)
        self.allTransfersView.stopAnimating()
    }
    
    func setReceivedTransfers(_ transfers: [EmittedGroupViewModel]) {
        self.receivedTransfersView.addResults(transfers)
        self.receivedTransfersView.stopAnimating()
    }
    
    func setEmittedTransfers(_ transfers: [EmittedGroupViewModel]) {
        self.issuedTransfersView.addResults(transfers)
        self.issuedTransfersView.stopAnimating()
    }
    
    func setEmptySearchedText(_ text: String) {
        self.allViews.forEach { $0.setEmptySearchedText(text) }
    }
    
    func setSearchedText(_ text: String, resultsNum: Int) {
        guard !text.isEmpty else { return visibleView.clearTableHeader() }
        self.visibleView.setTableHeaderText(text, resultsNumber: resultsNum)
    }
    
    func showComingSoon() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension HistoricalTransferViewController: SegmentedControlViewDelegate {
    func didSelectedIndexChanged(_ index: Int) {
        self.scrollToPage(page: index, animated: true)
        self.clearTextField()
        self.scrollToTop()
        self.presenter.didChangedSegmented(index)
    }
}

extension HistoricalTransferViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let position =
            scrollView.contentOffset.x < 0 ?
            0.0 : (scrollView.contentOffset.x > scrollView.contentSize.width ?
                    scrollView.contentSize.width : scrollView.contentOffset.x)
        
        let idx = Int(position / self.view.frame.width)
        if self.segmentedControlView.getSelectedSegmentIndex() != idx {
            self.segmentedControlView.setSegmentedIndex(idx)
            self.clearTextField()
            self.scrollToTop()
        }
    }
}

extension HistoricalTransferViewController: HistoricalTransferListViewDelegate {
    func didSelectTransfer(viewModel: TransferViewModel) {
        self.textField.endEditing(true)
        self.presenter.showTransferDetail(viewModel: viewModel)
    }
    
    func endEditing() {
        self.textField.endEditing(true)
    }
}

extension HistoricalTransferViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

private extension HistoricalTransferViewController {
    func configureAccessibilities() {
        self.scrollableView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferViewScroll
        self.textField.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferViewSearchTextField
        self.segmentedControlView.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferViewSegmentedField
    }
}

extension HistoricalTransferViewController: AccessibilityCapable { }
