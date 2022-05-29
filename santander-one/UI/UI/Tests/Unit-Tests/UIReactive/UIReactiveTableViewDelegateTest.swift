//
//  UIReactiveTableViewDelegateTest.swift
//  Cards-Unit-Tests
//
//  Created by Juan Carlos López Robles on 3/23/22.
//
import UI
import XCTest
import OpenCombine

class UIReactiveTableViewDelegateTest: XCTestCase {
    var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Given_delegatePublisher_When_didSelectRowAt_Then_publishSelectedRow() {
        let tableView = UITableView()
        let delegate = UIReactiveTableViewDelegate()
        tableView.delegate = delegate
        var expectedIndexPath: IndexPath?

        tableView.delegatePublisher?
        .case(UITableViewDelegateState.didSelectRowAt)
        .sink { (_, indexPath) in
            expectedIndexPath = indexPath
        }.store(in: &subscriptions)

        let selectedIndexPath = IndexPath(row: 1, section: 0)
        delegate.tableView(tableView, didSelectRowAt: selectedIndexPath)

        XCTAssertEqual(expectedIndexPath, selectedIndexPath)
    }
    
    func test_Given_delegatePublisher_When_didDeselectRowAt_Then_publishDeselectRow() {
        let tableView = UITableView()
        let delegate = UIReactiveTableViewDelegate()
        tableView.delegate = delegate
        var expectedIndexPath: IndexPath?

        tableView.delegatePublisher?
            .case(UITableViewDelegateState.didDeselectRowAt)
            .sink { (_, indexpath) in
                expectedIndexPath = indexpath
            }.store(in: &subscriptions)

        let deselectedIndexPath = IndexPath(row: 1, section: 0)
        delegate.tableView(tableView, didDeselectRowAt: deselectedIndexPath)

        XCTAssertEqual(expectedIndexPath, deselectedIndexPath)
    }

    func test_Given_delegatePublisher_When_willDisplay_Then_publishwillDisplayCell() {
        let tableView = UITableView()
        let delegate = UIReactiveTableViewDelegate()
        tableView.delegate = delegate

        var expectedIndexPath: IndexPath?
        var expectedTableViewCell: UITableViewCell?

        tableView.delegatePublisher?
            .case(UITableViewDelegateState.willDisplay)
            .sink { (_, cell, indexPath) in
                expectedTableViewCell = cell
                expectedIndexPath = indexPath
            }.store(in: &subscriptions)

        let willDisplayIndexPath = IndexPath(row: 1, section: 0)
        let willDisplayTableViewCell = UITableViewCell()
        delegate.tableView(tableView, willDisplay: willDisplayTableViewCell, forRowAt: willDisplayIndexPath)

        XCTAssertEqual(expectedIndexPath, willDisplayIndexPath)
        XCTAssertEqual(expectedTableViewCell, willDisplayTableViewCell)
    }

    func test_Given_delegatePublisher_When_didEndDisplayingCell_Then_publishEndDisplayingCell() {
        let tableView = UITableView()
        let delegate = UIReactiveTableViewDelegate()
        tableView.delegate = delegate

        var expectedIndexPath: IndexPath?
        var expectedTableViewCell: UITableViewCell?

        tableView.delegatePublisher?
            .case(UITableViewDelegateState.didEndDisplaying)
            .sink { _, cell, indexPath in
                expectedTableViewCell = cell
                expectedIndexPath = indexPath
            }.store(in: &subscriptions)

        let didEndDisplayingIndexPath = IndexPath(row: 1, section: 0)
        let didEndDisplayingTableViewCell = UITableViewCell()
        delegate.tableView(tableView, didEndDisplaying: didEndDisplayingTableViewCell, forRowAt: didEndDisplayingIndexPath)

        XCTAssertEqual(expectedIndexPath, didEndDisplayingIndexPath)
        XCTAssertEqual(expectedTableViewCell, didEndDisplayingTableViewCell)
    }

    func test_Given_delegatePublisher_When_itemAccessoryButtonTapped_Then_publishItemAccessoryButtonTapped() {
        let tableView = UITableView()
        let delegate = UIReactiveTableViewDelegate()
        tableView.delegate = delegate

        var expectedIndexPath: IndexPath?

        tableView.delegatePublisher?
            .case(UITableViewDelegateState.accessoryButtonTappedForRowWith)
            .sink { _, indexPath in
                expectedIndexPath = indexPath
            }
            .store(in: &subscriptions)

        let buttonTappedForRowWithIndexPath = IndexPath(row: 1, section: 0)
        delegate.tableView(tableView, accessoryButtonTappedForRowWith: buttonTappedForRowWithIndexPath)
        XCTAssertEqual(expectedIndexPath, buttonTappedForRowWithIndexPath)
    }
    
    func test_Given_delegatePublisher_When_didSelectRowAt_Then_notify_multiple_subscribers() {
        let tableView = UITableView()
        let delegate = UIReactiveTableViewDelegate()
        tableView.delegate = delegate

         var firstResultIndexPaths = [IndexPath]()
         var secondResultIndexPaths = [IndexPath]()

         tableView.delegatePublisher?
            .case(UITableViewDelegateState.didSelectRowAt)
            .sink { _, indexPath in
                firstResultIndexPaths.append(indexPath)
            }.store(in: &subscriptions)

         tableView.delegatePublisher?
            .case(UITableViewDelegateState.didSelectRowAt)
            .sink { _, indexPath in
                secondResultIndexPaths.append(indexPath)
            }.store(in: &subscriptions)

         let didSelectRowIndexPath = IndexPath(row: 1, section: 0)
         delegate.tableView(tableView, didSelectRowAt: didSelectRowIndexPath)

         XCTAssertEqual(firstResultIndexPaths, [didSelectRowIndexPath])
         XCTAssertEqual(firstResultIndexPaths, secondResultIndexPaths)
     }
}
