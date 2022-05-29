//
//  TimeLineDetailPageController.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 13/11/2019.
//

import UIKit

class TimeLineDetailPageController: UIPageViewController {
    var detailControllers = [TimeLineDetailViewController]()
    var currentEvent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        setControllers()
        setUI()
    }
    
    func setControllers() {
        setViewControllers([detailControllers[getCurrentControllerindex() ?? 0]], direction: .forward, animated: false) { _ in
            self.setCurrentEvent()
        }
    }
    
    func appendPrevious(detail: TimeLineDetailViewController) {
        if !alreadyAppended(detail: detail) {
            detailControllers.insert(detail, at: 0)
        }
        setControllers()
    }
    
    func appendComing(detail: TimeLineDetailViewController) {
        if !alreadyAppended(detail: detail) {
            detailControllers.insert(detail, at: detailControllers.count)
        }
        setControllers()
    }
    
    func alreadyAppended(detail: TimeLineDetailViewController) -> Bool {
        detailControllers.contains(where: {$0.presenter?.getDetail()?.identifier == detail.presenter?.getDetail()?.identifier})
    }
    
    func clear(with detail: TimeLineDetailViewController) {
        detailControllers = [detail]
        setControllers()
    }
    
}


// MARK: - UI
extension TimeLineDetailPageController {
    func setUI() {
        let view = UIView()
        let label = UILabel()
        label.text = TimeLineString().titleToolbar
        label.font = .santanderHeadline(type: .bold, with: 18)
        label.textColor = .sanRed
        view.addSubviewWithAutoLayout(label)
        view.layoutIfNeeded()
        view.sizeToFit()
        view.translatesAutoresizingMaskIntoConstraints = true
        navigationItem.titleView = view
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.reset()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .sky30
        self.navigationController?.navigationBar.setNavigationBarColor(.sky30)
        self.navigationController?.navigationBar.barStyle = .default
        self.redrawNavigationBar()
        self.extendedLayoutIncludesOpaqueBars = true
        configureBack()
        self.view.backgroundColor = .sky30


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
        let barButton = UIBarButtonItem(image: UIImage(fromModuleWithName: "iconBack"), style: .plain, target: self, action: #selector(onBackPressed))
        barButton.tintColor = .sanRed
        navigationItem.leftBarButtonItem = barButton
    }
    
    private func setCurrentEvent() {
        if let currentViewController = self.viewControllers?.first as? TimeLineDetailViewController {
            self.currentEvent = currentViewController.presenter?.getDetail()?.identifier
        }
    }
    
    @objc private func onBackPressed() {
        navigationController?.popWithTransition()
    }
}

// MARK: - DataSourse
extension TimeLineDetailPageController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = getCurrentControllerindex() else { return nil }
        return getControllerForBefore(index: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = getCurrentControllerindex() else { return nil }
        return getControllerForAfter(index: index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.setCurrentEvent()
        }
    }
    
    func getCurrentControllerindex() -> Int? {
        guard let index = detailControllers.firstIndex(where: {$0.presenter?.getDetail()?.identifier == currentEvent}) else { return nil }
        return index
    }
    
    func getControllerForBefore(index: Int) -> TimeLineDetailViewController? {
        if index >= 0 {
            return detailControllers[index]
        }
        return nil
    }
    
    func getControllerForAfter(index: Int) -> TimeLineDetailViewController? {
        if index >= 0, detailControllers.count - 1 >= index {
            return detailControllers[index]
        }
        return nil
    }
}


