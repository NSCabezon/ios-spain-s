import XCTest
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
@testable import GlobalPosition

final class AviosUseCaseTests: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private let mockDataInjector = MockDataInjector()
    
    override func setUp() {
        super.setUp()
        
        self.dependencies.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAvios_WhenCalledUseCaseWithOkResponse_ShouldReturnOK() {
        defaultRegistration()
        
        //Test
        let useCase = GetAviosDetailInfoUseCase(dependenciesResolver: dependencies)
        let response: UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>
        do {
            response = try useCase.executeUseCase(requestValues: ())
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        //Consult
        XCTAssert(response.isOkResult)
    }
    
    func testAvios_WhenCalledUseCaseWithOkResponse_ShouldntThrowOnReturnData() {
        defaultRegistration()
        
        //Test
        let useCase = GetAviosDetailInfoUseCase(dependenciesResolver: dependencies)
        let response: UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>
        do {
            response = try useCase.executeUseCase(requestValues: ())
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        //Consult
        XCTAssertNoThrow(try response.getOkResult())
    }
    
    func testAvios_WhenCalledUseCaseWithOkResponse_ShouldReturnData() {
        defaultRegistration()
        
        //Test
        let useCase = GetAviosDetailInfoUseCase(dependenciesResolver: dependencies)
        let response: UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>
        do {
            response = try useCase.executeUseCase(requestValues: ())
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        //Consult
        let okResult = try! response.getOkResult()
        XCTAssertNotNil(okResult.detail.iberiaPlusCode)
        XCTAssertNotNil(okResult.detail.lastLiquidationTotalPoints)
        XCTAssertNotNil(okResult.detail.totalPoints)
    }
    
    func testAvios_WhenCalledUseCaseWithEmptyResponse_ShouldReturnOK() {
        defaultRegistration()
        
        //Test
        let useCase = GetAviosDetailInfoUseCase(dependenciesResolver: dependencies)
        let response: UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>
        do {
            response = try useCase.executeUseCase(requestValues: ())
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        //Consult
        XCTAssert(response.isOkResult)
    }
    
    func testAvios_WhenCalledUseCaseWithEmptyResponse_ShouldntThrowOnReturnData() {
        defaultRegistration()
        
        //Test
        let useCase = GetAviosDetailInfoUseCase(dependenciesResolver: dependencies)
        let response: UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>
        do {
            response = try useCase.executeUseCase(requestValues: ())
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        //Consult
        XCTAssertNoThrow(try response.getOkResult())
    }

    func testAvios_WhenCalledUseCaseWithEmptyResponse_ShouldntReturnData() {
        //Prepare
        registerEmptyResonse()
        
        //Test
        let useCase = GetAviosDetailInfoUseCase(dependenciesResolver: dependencies)
        let response: UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>
        do {
            response = try useCase.executeUseCase(requestValues: ())
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        //Consult
        let okResult = try! response.getOkResult()
        XCTAssertNil(okResult.detail.iberiaPlusCode)
        XCTAssertNil(okResult.detail.lastLiquidationTotalPoints)
        XCTAssertNil(okResult.detail.totalPoints)
    }
    
    func testAvios_WhenCalledUseCaseWithErrorResponse_ShouldReturnError() {
        //Test
        let useCase = GetAviosDetailInfoUseCase(dependenciesResolver: dependencies)
        let response: UseCaseResponse<GetAviosDetailInfoUseCaseOkOutput, StringErrorOutput>
        do {
            response = try useCase.executeUseCase(requestValues: ())
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }
        
        //Consult
        XCTAssertFalse(response.isOkResult)
    }
}

private extension AviosUseCaseTests {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getAviosDetail,
            filename: "aviosDetail"
        )
    }
    
    func registerEmptyResonse() {
        self.mockDataInjector.register(
            for: \.gpData.getAviosDetail,
            filename: "aviosDetailEmpty"
        )
    }
}
