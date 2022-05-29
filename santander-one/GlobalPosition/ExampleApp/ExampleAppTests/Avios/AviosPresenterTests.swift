import XCTest
import CoreFoundationLib
import SANLegacyLibrary
@testable import GlobalPosition

extension AviosPresenterTests {
    enum Constants {
        static var aviosDetailDtoMock: AviosDetailDTO {
            return AviosDetailDTO(
                totalPoints: 1234,
                iberiaPlusCode: "123456",
                lastLiquidationTotalPoints: 34
            )
        }
        
        static var aviosDetailDtoOneNilMock: AviosDetailDTO {
            return AviosDetailDTO(
                totalPoints: 1234,
                iberiaPlusCode: nil,
                lastLiquidationTotalPoints: 34
            )
        }
        
        static var aviosDetailDtoTwoNilMock: AviosDetailDTO {
            return AviosDetailDTO(
                totalPoints: 1234,
                iberiaPlusCode: nil,
                lastLiquidationTotalPoints: nil
            )
        }
    }
}

final class AviosPresenterTests: XCTestCase {
    private let view: AviosDetailViewProtocol = AviosDetailViewMock()
    private let coordinator: AviosDetailCoordinatorProtocol = AviosDetailCoordinatorProtocolMock()
    private let usecaseHandler: UseCaseHandler = UseCaseHandler()
    private let emptyLiteral = "- -"

    private var dependencies: DependenciesResolver!
    private var aviosDetailInfoUseCase: GetAviosDetailInfoUseCaseMock!
    private var presenter: AviosDetailPresenterProtocol!

    override func setUp() {
        super.setUp()
        dependencies = getDependenciesResolver()
        presenter = AviosDetailPresenter(dependenciesResolver: dependencies)
        aviosDetailInfoUseCase = GetAviosDetailInfoUseCaseMock()
        presenter.view = view
    }
    
    private func getDependenciesResolver() -> DependenciesResolver {
        let dependenciesEngine = DependenciesDefault()
        dependenciesEngine.register(for: GetAviosDetailInfoUseCaseAlias.self) { dependenciesResolver in
            return self.aviosDetailInfoUseCase
        }
        dependenciesEngine.register(for: AviosDetailCoordinatorProtocol.self) { dependenciesResolver in
            return self.coordinator
        }
        dependenciesEngine.register(for: AviosDetailViewProtocol.self, with: { _ in
            return self.view
        })
        dependenciesEngine.register(for: UseCaseHandler.self, with: { _ in
            return self.usecaseHandler
        })

        return dependenciesEngine
    }
    
    override func tearDown() {
        super.tearDown()
        dependencies = nil
        presenter = nil
        aviosDetailInfoUseCase = nil
    }
    
    // MARK: - didTapClose
    
    func testAvios_WhenCallingDidTapClose_ThenCoordinatorShouldDismiss() {
        //Prepare
        let predicate = NSPredicate { (coordinator: Any?, _) -> Bool in
            guard let coordinator: AviosDetailCoordinatorProtocolMock = coordinator as? AviosDetailCoordinatorProtocolMock else {
                return false
            }
            return coordinator.hasBeenDismissed == true
        }
        
        //Test
        _ = expectation(for: predicate, evaluatedWith: coordinator, handler: .none)
        presenter?.didTapClose()

        //Consult
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    // MARK: - loadAviosInfo
    
    func testAvios_WhenCallingViewDidLoad_AndDoesntHaveData_ThenTheModelShouldHaveTheEmptyLiteralValues() {
        //Prepare
        aviosDetailInfoUseCase.setAviosDetail(aviosDetailDTO: nil)
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: AviosDetailViewMock = view as? AviosDetailViewMock else {
                return false
            }
            return view.model != nil
                && view.model.iberiaCode == self.emptyLiteral
                && view.model.totalPoints == self.emptyLiteral
                && view.model.lastLiquidationPoints == self.emptyLiteral
        }
        
        //Test
        _ = expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter?.viewDidLoad()

        //Consult
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    func testAvios_WhenCallingViewDidLoad_AndHasData_ThenTheModelShouldHaveRealValues() {
        //Prepare
        aviosDetailInfoUseCase.setAviosDetail(aviosDetailDTO: Constants.aviosDetailDtoMock)
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: AviosDetailViewMock = view as? AviosDetailViewMock else {
                return false
            }
            return view.model != nil
                && view.model.iberiaCode != self.emptyLiteral
                && view.model.totalPoints != self.emptyLiteral
                && view.model.lastLiquidationPoints != self.emptyLiteral
        }
        
        //Test
        _ = expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter?.viewDidLoad()

        //Consult
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    // MARK: Unavailable data
    
    func testAvios_WhenCallingViewDidLoad_AndDoesntHaveData_ThenShouldHaveUnavailableDataInformation() {
        //Prepare
        aviosDetailInfoUseCase.setAviosDetail(aviosDetailDTO: nil)
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: AviosDetailViewMock = view as? AviosDetailViewMock else {
                return false
            }
            return view.hasUnavailableData == true
        }
        
        //Test
        _ = expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter?.viewDidLoad()

        //Consult
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    func testAvios_WhenCallingViewDidLoad_AndHasData_ThenShouldntHaveUnavailableDataInformation() {
        //Prepare
        aviosDetailInfoUseCase.setAviosDetail(aviosDetailDTO: Constants.aviosDetailDtoMock)
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: AviosDetailViewMock = view as? AviosDetailViewMock else {
                return false
            }
            return view.hasUnavailableData == false
        }
        
        //Test
        _ = expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter?.viewDidLoad()

        //Consult
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    func testAvios_WhenCallingViewDidLoad_AndHasDataWithOneNil_ThenShouldntHaveUnavailableDataInformation() {
        //Prepare
        aviosDetailInfoUseCase.setAviosDetail(aviosDetailDTO: Constants.aviosDetailDtoOneNilMock)
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: AviosDetailViewMock = view as? AviosDetailViewMock else {
                return false
            }
            return view.hasUnavailableData == false
        }
        
        //Test
        _ = expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter?.viewDidLoad()

        //Consult
        waitForExpectations(timeout: 5, handler: .none)
    }
    
    func testAvios_WhenCallingLoadAviosInfo_AndHasDataWithTwoNil_ThenShouldntHaveUnavailableDataInformation() {
        //Prepare
        aviosDetailInfoUseCase.setAviosDetail(aviosDetailDTO: Constants.aviosDetailDtoTwoNilMock)
        let predicate = NSPredicate { (view: Any?, _) -> Bool in
            guard let view: AviosDetailViewMock = view as? AviosDetailViewMock else {
                return false
            }
            return view.hasUnavailableData == false
        }
        
        //Test
        _ = expectation(for: predicate, evaluatedWith: view, handler: .none)
        presenter?.viewDidLoad()

        //Consult
        waitForExpectations(timeout: 5, handler: .none)
    }
}

// MARK: - Mocks

final class AviosDetailCoordinatorProtocolMock: AviosDetailCoordinatorProtocol {
    var hasBeenDismissed: Bool
    
    init() {
        hasBeenDismissed = false
    }
    
    func dismiss() {
        hasBeenDismissed = true
    }
}

final class AviosDetailViewMock: AviosDetailViewProtocol {
    var associatedLoadingView: UIViewController
    var hasUnavailableData: Bool
    var model: AviosDetailComponentViewModel!
    
    init() {
        associatedLoadingView = UIViewController()
        hasUnavailableData = false
    }

    func setAviosDetail(model: AviosDetailComponentViewModel) {
        self.model = model
    }
    
    func setUnavailableData() {
        hasUnavailableData = true
    }
    
    func startLoading(completion: @escaping (() -> Void)) {
        completion()
    }
    
    func stopLoading(completion: @escaping (() -> Void)) {
        completion()
    }
}

final class GetAviosDetailInfoUseCaseMock: GetAviosDetailInfoUseCaseAlias {
    private(set) var aviosDetailDTO: AviosDetailDTO = AviosDetailDTO(totalPoints: nil, iberiaPlusCode: nil, lastLiquidationTotalPoints: nil)
    
    func setAviosDetail(aviosDetailDTO: AviosDetailDTO?) {
        self.aviosDetailDTO = aviosDetailDTO ?? AviosDetailDTO(totalPoints: nil, iberiaPlusCode: nil, lastLiquidationTotalPoints: nil)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetAviosDetailInfoUseCaseOkOutput(detail: AviosDetail(aviosDetailDTO)))
    }
}
