//
//  TimeLineViewController.swift
//  IB-FinantialTimeline-iOS
//
//  Created by Antonio Muñoz Nieto on 27/06/2019.
//

import UIKit
import Foundation
import AudioToolbox
import CoreFoundationLib

public class TimeLineViewController: UIViewController {
    @IBOutlet weak var timelineTableView: UITableView!
    @IBOutlet weak var bottomLoader: UIImageView!
    @IBOutlet weak var topLoader: UIImageView!
    @IBOutlet weak var bottomLoaderHeight: NSLayoutConstraint!
    @IBOutlet weak var topLoaderHeight: NSLayoutConstraint!
    @IBOutlet weak var monthsSelectoHeight: NSLayoutConstraint!
    @IBOutlet weak var loadingLabelContainerView: UIView!
    @IBOutlet weak var safeConnectionLabel: UILabel!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var loadingTitle: UILabel!
    @IBOutlet weak var loadingDescription: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var titleErrorLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleErrorWidgetLabel: UILabel!
    @IBOutlet weak var errorWidgetView: UIView!
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var subtitleErrorWidgetLabel: UILabel!
    @IBOutlet weak var errorWidgetImageView: UIImageView!
    @IBOutlet weak var errorImageHeight: NSLayoutConstraint!
    @IBOutlet weak var errorImageWidth: NSLayoutConstraint!
    @IBOutlet weak var monthsSelectorContainer: UIView!
    @IBOutlet weak var menuView: MenuView!
    @IBOutlet weak var monthSeparatorView: UIView!
    @IBOutlet weak var stackViewError: UIStackView!
    var strategy: TLStrategy?
    var lastLoadedDate: Date?
    var didScrool = false
    var textsEngine: TextsEngine?
    var presenter: TimeLinePresenterProtocol?
    internal var timeLineSections: [TimeLineSection] = []
    internal var isLoadMoreComingEventsAvailable: Bool {
        return presenter?.isLoadMoreComingEventsAvailable ?? false
    }
    internal var isLoadMorePreviousEventsAvailable: Bool {
        return presenter?.isLoadMorePreviousEventsAvailable ?? false
    }
    internal var monthSelector: TimeLineMonthSelector?
    internal var scrollToBottomTodayBlocked: Bool = true
    internal var scrollToTopTodayBlocked: Bool = true
    internal var todayIndexPath: IndexPath? {
        let today = TimeLine.dependencies.configuration?.currentDate ?? Date()
        return timeLineSections.indices(where: \.date, block: {
            today.isSameDay(than: $0)
        }).map({ IndexPath.init(row: $1, section: $0) })
    }
    internal enum ScrollDirection {
        case top
        case bottom
    }
    internal var scrollDirection: ScrollDirection {
        if timelineTableView.panGestureRecognizer.translation(in: timelineTableView.superview).y > 0 {
            return .top
        } else {
            return .bottom
        }
    }
    
    var customAlert: AlertBarView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.scrollsToTop = false
        presenter?.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.enablePopGesture()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func configureView() {
        timelineTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        timelineTableView.backgroundColor = .white
        timelineTableView.sectionHeaderHeight = 0
        timelineTableView.tableHeaderView = UIView(frame: .zero)
        errorView.layer.borderWidth = 1
        errorView.layer.borderColor = UIColor.turquoise.withAlphaComponent(0.40).cgColor
        titleErrorLabel.textColor = .blueGreen
        titleErrorLabel.font = .santanderText(type: .bold, with: 20)
        errorLabel.textColor = .blueGreen
        errorLabel.textAlignment = .center
        errorLabel.font = .santanderText(type: .regular, with: 14)
        errorImage.tintColor = .turquoise
        errorView.isHidden = true
        monthSeparatorView.isHidden = true
        errorWidgetView.isHidden = true
        timelineTableView.isHidden = true
        loadingTitle.font = .santanderText(with: 16)
        loadingTitle.textAlignment = .center
        loadingTitle.textColor = .brownishGrey
        loadingDescription.font = .santanderText(with: 14)
        loadingDescription.textAlignment = .center
        loadingDescription.textColor = .brownishGrey
        safeConnectionLabel.font = .santanderHeadline(type: .regular, with: 14)
        safeConnectionLabel.textColor = .brownishGrey
        self.loadingContainerView.backgroundColor = .clear
        self.loadingView.backgroundColor = .clear
    }
    
    func setupNavigationBar() {
        customAlert = AlertBarView(from: self)
        self.reset()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .sky30
        self.navigationController?.navigationBar.setNavigationBarColor(.sky30)
        self.navigationController?.navigationBar.barStyle = .default
        self.redrawNavigationBar()
        self.extendedLayoutIncludesOpaqueBars = true
        configureTitle()
        configureBack()
    }

    private func redrawNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func reset() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func configureBack() {
        let barButton = UIBarButtonItem(image: UIImage(fromModuleWithName: "iconBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onBackPressed))
        barButton.tintColor = .sanRed
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc private func onBackPressed() {
        presenter?.didSelectBack()
    }
    
    internal func configureTitle() {
        let view = UIView()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        let label = UILabel()
        label.text = TimeLineString().titleToolbar
        label.font = .santanderHeadline(type: .bold, with: 18)
        label.textColor = .sanRed
        stackView.addArrangedSubview(label)
        let button = UIButton()
        button.setImage(UIImage(fromModuleWithName: "icTooltip")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = .sanRed
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.addTarget(self, action: #selector(showTooltip(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(button)
        view.addSubviewWithAutoLayout(stackView)
        view.layoutIfNeeded()
        view.sizeToFit()
        view.translatesAutoresizingMaskIntoConstraints = true
        navigationItem.titleView = view
    }
    
    @objc internal func showTooltip(_ sender: UIButton) {
        let tooltip = ToolTip(
            title: TimeLineString().titleToolbar,
            description: TimeLineString().infoToolbar,
            sourceViewController: self,
            sourceView: sender,
            sourceFrame: sender.bounds,
            arrowDirection: .up
        )
        tooltip.show()
    }
    
    @objc func loadMorePreviousEvents() {
        if isLoadMorePreviousEventsAvailable {
            addTopLoader()
            presenter?.loadMorePreviousTimeLineEvents()
        } else {
            hideTopLoader()
        }
    }
    
    internal func addTopLoader() {
        topLoaderHeight.constant = strategy?.getTopLoaderHeight() ?? 0
        topLoader.setAnimationImagesWith(prefixName: "BS_s-loader-", range: 1...48)
        topLoader.startAnimating()
    }
    
    internal func hideTopLoader() {
        self.topLoaderHeight.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        topLoader.stopAnimating()
    }
    
    internal func addBottomLoader() {
        bottomLoaderHeight.constant = strategy?.getTopLoaderHeight() ?? 0
        bottomLoader.setAnimationImagesWith(prefixName: "BS_s-loader-", range: 1...48)
        bottomLoader.startAnimating()
    }
    
    internal func hideBottomLoader() {
        bottomLoaderHeight.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        bottomLoader.stopAnimating()
    }
    
    internal enum State {
        case failure(String, Error, TimeLineEventsErrorType)
        case loading
        case success([TimeLineSection])
    }
    
    private func updateViewState(_ state: State, completion: (() -> Void)? = nil) {
        switch state {
        case .failure(let title, let error, let type):
            strategy?.onFailure(with: title, error: error, type: type)
        case .loading:
            strategy?.onLoading()
        case .success(let sections):
            strategy?.onSucces(with: sections) {
                completion?()
            }
        }
    }
    
    private func enablePopGesture() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: #selector(onBackPressed))
    }
    
    internal func scrollToLastDate() {
        switch scrollDirection {
        case .top:
            scrollToTop()
        default:
            break
        }
    }
    
    internal func scrollToTop() {
        scrollTo(.top)
       
    }
    
    internal func scrollToMiddle() {
        scrollTo(.middle)
    }
    
    internal func scrollTo(_ position: UITableView.ScrollPosition) {
        self.didScrool = false
        guard
            let date = self.lastLoadedDate,
            let indexPath = self.timeLineSections.indices(where: \.date, block: {
                date.isSameDay(than: $0)
            }).map({ IndexPath.init(row: $1, section: $0) })
        else {
            return
        }
        self.timelineTableView.scrollToRow(at: indexPath, at: position, animated: false)
        DispatchQueue.main.async {
            self.didScrool = true
        }
    }

    
    internal func selectCurrentFirstMonth() {
        guard
            let indexPathsForVisibleRows = timelineTableView.indexPathsForVisibleRows,
            let monthSelector = self.monthSelector
        else {
            return
        }
        
        guard let date = indexPathsForVisibleRows.map({ timeLineSections[$0.section] }).firstDate(),
        monthSelector.selectMonth(date) else { return }
    }
}


// MARK: - UITableView
extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return timeLineSections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch timeLineSections[section] {
        case .error:
            return 1
        case .eventsByDate(_, let events):
            return events.count
        case .month:
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch timeLineSections[indexPath.section] {
        case .error(error: let error):
            let cell = tableView.dequeueReusableCell(type: TimeLineErrorCell.self)
            cell.setup(with: error)
            return cell
        case .eventsByDate(date: let date, timeLineEvent: let events):
            defer {
                pagination(with: indexPath, date: date, and: events)
            }
            guard let cell = getTimeLineCell(tableView, with: indexPath, events: events, and: date) else { return UITableViewCell() }
            return cell
        case .month(date: let date):
            defer {
                pagination(with: indexPath, date: date, and: [])
            }
            let cell = tableView.dequeueReusableCell(type: TimeLineSeparatorMounth.self)
            cell.setDate(date: date.string(format: .MMMyyyy)
                            .uppercased()
                            .replacingOccurrences(of: ".", with: ""))
            cell.setBackground(date: date)
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        if timeLineSections.indices.last != section {
            let view = tableView.dequeueReusableCell(withIdentifier: "TimeLineEndCell")
            if timeLineSections[section].date() ?? timeLineSections[section+1].date() ?? Date() > Date() {
                view?.backgroundColor = .backgroundFutureCell
            } else {
                view?.backgroundColor = .white
            }
            return view
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        if timeLineSections.indices.last != section {
            return 10
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = timeLineSections[indexPath.section]
        switch section {
        case .eventsByDate(date: _, timeLineEvent: let events):
            presenter?.didSelectTimeLineEvent(events[indexPath.row])
        default:
            break
        }
    }
}

// MARK: - UITableView helpers
extension TimeLineViewController {
    // Pagination
    private func pagination(with indexPath: IndexPath, date: Date, and events: [TimeLineEvent]) {
        if self.isLoadMoreComingEventsAvailable, self.timeLineSections.count - 1 == indexPath.section, events.count - 1 == indexPath.row {
            self.lastLoadedDate = self.timeLineSections.allDates().sorted().last
            self.presenter?.loadMoreComingTimeLineEvents()
            self.addBottomLoader()
        }
        if self.isLoadMorePreviousEventsAvailable, self.timelineTableView.contentOffset.y <= 0 {
            self.lastLoadedDate = self.timeLineSections.allDates().sorted().first
            self.presenter?.loadMorePreviousTimeLineEvents()
            self.addTopLoader()
        }
    }
    
    // set TimeLineCell
    private func getTimeLineCell(_ tableView: UITableView, with indexPath: IndexPath, events: [TimeLineEvent], and date: Date) -> TimeLineCell? {
        guard let textsEngine = self.textsEngine else { return nil }
        let cell: TimeLineCell
         if indexPath.row == 0 && date.isSameDay(than: TimeLine.dependencies.configuration?.currentDate ?? Date()) {
            if events[indexPath.row].transaction.transactionTypeString == TimeLineEvent.TransactionType.noEvent.rawValue {
                cell = tableView.dequeueReusableCell(type: TimeLineNotTodayCell.self)
                let dateFormatted = date.getToday().replacingOccurrences(of: ".", with: "")
                cell.setDateNoTodayDateCell(date: dateFormatted)
            } else {
                cell = tableView.dequeueReusableCell(type: TimeLineTodayCell.self)
                let dateFormatted = date.getToday().replacingOccurrences(of: ".", with: "")
                cell.setDateTodayDateCell(date: dateFormatted)
            }
         } else if date.isSameDay(than: TimeLine.dependencies.configuration?.currentDate ?? Date()) {
            cell = tableView.dequeueReusableCell(type: TimeLineTodayNotDateCell.self)
        } else if indexPath.row == 0 {
            cell = date.compare(TimeLine.dependencies.configuration?.currentDate ?? Date()) == .orderedAscending ? tableView.dequeueReusableCell(type: TimeLinePreviousDateCell.self) :  tableView.dequeueReusableCell(type: TimeLineDateCell.self)
            
        } else {
            if date.isSameDay(than: TimeLine.dependencies.configuration?.currentDate ?? Date()) || date.compare(TimeLine.dependencies.configuration?.currentDate ?? Date()) == .orderedDescending {
                cell = tableView.dequeueReusableCell(type: TimeLineCell.self)
            } else {
                cell = tableView.dequeueReusableCell(type: TimeLinePreviousCell.self)
            }
        }
        cell.setup(with: events[indexPath.row], textsEngine: textsEngine, strategy: strategy, delegate: self)
        if (events.count - 1) == indexPath.row {
            cell.addShadowCell()
        } else {
            cell.deleteShadowCell()
        }
        return cell
    }
    
}

extension TimeLineViewController: TimeLineViewProtocol {
    
    func timeLineDidFail(title: String, error: Error, type: TimeLineEventsErrorType) {
        updateViewState(.failure(title, error, type))
    }
    
    func comingTimeLineLoaded(withSections sections: [TimeLineSection]) {
        updateViewState(.success(sections)) { [weak self] in
            self?.hideBottomLoader()
        }
    }
    
    func previousTimeLineLoaded(withSections sections: [TimeLineSection]) {
        updateViewState(.success(sections)){ [weak self] in
            self?.hideTopLoader()
        }
    }
    
    func showMonthSelector(months: [Date]) {
        self.monthsSelectorContainer.backgroundColor = .sky30
        let monthSelector = TimeLineMonthSelector(months: months, delegate: self)
        monthsSelectorContainer.addSubviewWithAutoLayout(monthSelector, bottomAnchorConstant: .equal(to: -7))
        self.monthSelector = monthSelector
    }
    
    func showLoadingIndicator() {
        updateViewState(.loading)
    }
    
    func move(to event: TimeLineEvent) {
        guard let indices = self.timeLineSections.indices(where: \.identifier, value: event.identifier) else { return }
        self.timelineTableView.scrollToRow(at: IndexPath(row: indices.1, section: indices.0), at: .top, animated: false)
        
        DispatchQueue.main.async {
            self.didScrool = true
        }
    }
    
    func showAlert(message: String) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { 
            self.customAlert.showAlertBar(messageHTML: message)
        }
    }
    
    func showMenuOptions(_ items: [MenuItem]) {
        menuView.set(items)
    }
    
    func scrollToToday() {
        guard let index = todayIndexPath else { return }
        timelineTableView.scrollToRow(at: index, at: .middle, animated: false)
        presenter?.setFirstLoad()
    }
}

extension TimeLineViewController: TimeLineMonthSelectorDelegate {
    
    func didSelectMonth(_ month: Date) {
        didScrool = false
        presenter?.didSelectMonth(month)
    }
}

extension TimeLineViewController: StoryBoardInstantiable {
    static func storyboardName() -> String {
        return "TimeLine"
    }
}

extension TimeLineViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectCurrentFirstMonth()
        guard let todayIndexPath = self.todayIndexPath else { return }
        let rect = timelineTableView.rectForRow(at: todayIndexPath)
        guard !scrollView.bounds.contains(rect) else {
            scrollToTopTodayBlocked = true
            scrollToBottomTodayBlocked = true
            return
        }
        // Today cell is not visible
        switch scrollDirection {
        case .bottom:
            guard scrollView.contentOffset.y > rect.origin.y else { return }
            scrollToTopTodayBlocked = false
        case .top:
            guard scrollView.contentOffset.y < rect.origin.y else { return }
            scrollToBottomTodayBlocked = false
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let todayIndexPath = self.todayIndexPath else { return }
        let rect = timelineTableView.rectForRow(at: todayIndexPath)
        guard !scrollView.bounds.contains(rect) else { return }
        // Today cell is not visible
        let cellRect = rect.origin.y + rect.size.height
        switch scrollDirection {
        case .top:
            guard !scrollToTopTodayBlocked, targetContentOffset.move().y < cellRect else { return }
            scrollToTopTodayBlocked = true
            targetContentOffset.pointee = scrollView.contentOffset
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            timelineTableView.scrollToRow(at: todayIndexPath, at: .middle, animated: true)
        case .bottom:
            guard !scrollToBottomTodayBlocked, targetContentOffset.move().y > cellRect else { return }
            scrollToBottomTodayBlocked = true
            targetContentOffset.pointee = scrollView.contentOffset
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            timelineTableView.scrollToRow(at: todayIndexPath, at: .middle, animated: true)
        }
    }
}

extension TimeLineViewController: TimeLineCellDelegate {
    func trackLink(with url: URL) {
        presenter?.trackLink(with: url)
    }
}

extension SystemSoundID {
    static func playSound(soundName: String, fileExtension: String) {
        var soundID: SystemSoundID = 0
        if let filePath = Bundle.module?.path(forResource: soundName, ofType: fileExtension) {
            let pathToResource = NSURL(fileURLWithPath: filePath)
            AudioServicesCreateSystemSoundID(pathToResource, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
