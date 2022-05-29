import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

//TIENEN QUE ESTAR AQUI PORQUE PARA CADA TESTS SE RESETEAN LAS VARIABLES QUE
//ESTAN DENTRO DE LA CLASE, LO QUE OBLIGARIA A HACER LOGIN PARA CADA TEST
var dataRepository : DataRepositoryImpl?
var bsanPGManager : BSANPGManager?
var bsanAccountManager : BSANAccountsManager?
var bsanCardsManager : BSANCardsManager?
var bsanBizumManager: BSANBizumManager?
var bsanLoanManager : BSANLoansManager?
var bsanFundManager : BSANFundsManager?
var bsanPensionManager : BSANPensionsManager?
var bsanDepositsManager : BSANDepositsManager?
var bsanStocksManager : BSANStocksManager?
var bsanInsurancesManager : BSANInsurancesManager?
var bsanLoanSimulatorManager: BSANLoanSimulatorManager?
var bsanPortfoliosManager : BSANPortfoliosPBManager?
var bsanSignatureManager : BSANSignatureManager?
var bsanAuthManager : BSANAuthManager?
var bsanBillTaxesManager: BSANBillTaxesManager?
var bsanSociusManager: BSANSociusManager?
var bsanManagersManager: BSANManagersManager?
var bsanPersonDataManager: BSANPersonDataManager?
var bsanMobileRechargeManager: BSANMobileRechargeManager?
var bsanTransfersManager: BSANTransfersManager?
var bsanCashWithdrawalManager: BSANCashWithdrawalManager?
var bsanCesManager: BSANCesManager?
var bsanSendMoneyManager: BSANSendMoneyManager?
var bsanMifidManager: BSANMifidManager?
var bsanOTPPushManager: BSANOTPPushManager?
var bsanScaManager: BSANScaManager?
var bsanPendingSolicitudesManager: BSANPendingSolicitudesManager?
var bsanTimelineManager: BSANTimeLineManager?
var bsanOnePlanManager: BSANOnePlanManager?
var bsanLastLogonManager: BSANLastLogonManager?
var bsanFavouriteTransfersManager: BSANFavouriteTransfersManager?
var bsanRecoveryNoticesManager: BSANRecoveryNoticesManager?
var bsanAviosManager: BSANAviosManager?
var bsanBranchLocatorManager: BSANBranchLocatorManager?
var bsanEcommerceManager: BSANEcommerceManager?
var bsanSignBasicOperationManager: BSANSignBasicOperationManager?
var bsanSubscriptionManager: BSANSubscriptionManager?
var bsanFintechManager: BSANFintechManager?
var environmentDTO = BSANEnvironments.enviromentPreWas9
var loginUser = LOGIN_USER.ACCOUNTS_LOGIN

class BaseLibraryTests: XCTestCase {
    
    class TestsKeychainService: KeychainService {
        let account = "INSTALLATION_DATA"
        let service = "myService"
        let accessGroupName: String? = nil
    }
    
    private(set) var isPb: Bool = false
    
    var shouldLoadGlobalPositionV2: Bool = false
    
    var alamofireManager : Alamofire.SessionManager?
    var appInfo : VersionInfoDTO?
    var udDataSource: UDDataSource?
    var memoryDataSource : MemoryDataSource?
    var hybridDataSource : HybridDataSource?
    var dataSources: [DataSource]?
    var bsanDataProvider : BSANDataProvider?
    var webServicesUrlProvider : WebServicesUrlProvider?
    var sanSoapServicesImpl : SanSoapServicesImpl?
    var sanRestServicesImpl : SanRestServicesImpl?
    var sanJsonRestServicesImpl: SanRestServices?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        login(isPb: isPb)
    }
    
    func setUp(loginUser: LOGIN_USER, pbToSet: Bool?) {
        setLoginUser(newLoginUser: loginUser)
        resetDataRepository()
        if let pbToSet = pbToSet{
            self.isPb = pbToSet
        }
        setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func setLoginUser(newLoginUser: LOGIN_USER){
        if loginUser != newLoginUser{
            loginUser = newLoginUser
            isPb = newLoginUser.isPb
        }
    }
    
    func resetDataRepository(){
        if let dataRepository = dataRepository{
            dataRepository.remove(SessionData.self)
        }
    }
    
    func addMulMovHeader(_ urlList: [String]) {
        self.webServicesUrlProvider?.setUrlsForMulMov(urlList)
    }
    
    func login(isPb: Bool){
        
        //SI HAY SESION CREADA (YA SE HA LLAMADO A POSICION GLOBAL) NO SE VUELVE A LLAMAR
        if let _ = getSessionData() {
            return
        }
        
        alamofireManager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: CustomServerTrustPoliceManager()
        )
        
        appInfo = VersionInfoDTO(bundleIdentifier: "com.sanlib.test", versionName: "1.0.0")
        udDataSource = UDDataSource(serializer: JSONSerializer(), appInfo: appInfo!, keychainService: TestsKeychainService())
        memoryDataSource = MemoryDataSource()
        hybridDataSource = HybridDataSource(memoryDataSource: memoryDataSource!, udDataSource: udDataSource!)
        dataSources = [hybridDataSource!, udDataSource!, memoryDataSource!]
        dataRepository = DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: hybridDataSource!, dataSources: dataSources!), appInfo: appInfo!)
        bsanDataProvider = BSANDataProvider(dataRepository: dataRepository!, appInfo: appInfo!)
        bsanDataProvider!.storeEnviroment(environmentDTO)
        webServicesUrlProvider = WebServicesUrlProviderImpl(bsanDataProvider: bsanDataProvider!)
        sanSoapServicesImpl = SanSoapServicesImpl(callExecutor: AlamoExecutor(alamofireManager!), demoExecutor: SoapDemoExecutor(bsanDataProvider: bsanDataProvider!), bsanDataProvider: bsanDataProvider!)
        sanRestServicesImpl = SanRestServicesImpl(callExecutor: RestAlamoExecutor(alamofireManager!, webServicesUrlProvider: webServicesUrlProvider!, bsanDataProvider: bsanDataProvider!), demoExecutor: RestDemoExecutor(), bsanDataProvider: bsanDataProvider!)
        sanJsonRestServicesImpl = SanRestServicesImpl(callExecutor: RestJSONAlamoExecutor(alamofireManager!, webServicesUrlProvider: webServicesUrlProvider!, bsanDataProvider: bsanDataProvider!), demoExecutor: RestDemoExecutor(), bsanDataProvider: bsanDataProvider!)
        bsanPGManager = BSANPGManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanAccountManager = BSANAccountsManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!, sanRestServices: sanJsonRestServicesImpl!)
        bsanCardsManager = BSANCardsManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!, sanRestServices: sanJsonRestServicesImpl!)
        bsanBizumManager = BSANBizumManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanLoanManager = BSANLoansManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanFundManager = BSANFundsManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanPensionManager = BSANPensionsManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanDepositsManager = BSANDepositsManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanStocksManager = BSANStocksManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanPortfoliosManager = BSANPortfoliosPBManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanSignatureManager = BSANSignatureManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanAuthManager = BSANAuthManagerImplementation(sanSoapServices: sanSoapServicesImpl!, sanRestServices: sanRestServicesImpl!, bsanDataProvider: bsanDataProvider!, authDataSource: AuthDataSourceImpl(sanRestServices: sanRestServicesImpl!), webServicesUrlProvider: webServicesUrlProvider!)
        bsanInsurancesManager = BSANInsurancesManagerImplementation(bsanDataProvider: bsanDataProvider!, bsanAuthManager: bsanAuthManager!, sanRestServices: sanRestServicesImpl!, webServicesUrlProvider: webServicesUrlProvider!)
        bsanLoanSimulatorManager = BSANLoanSimulatorManagerImplementation(bsanDataProvider: bsanDataProvider!, bsanAuthManager: bsanAuthManager!, sanRestServices: sanJsonRestServicesImpl!)
        bsanBillTaxesManager = BSANBillTaxesManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!, sanRestServices: sanRestServicesImpl!)
        bsanSociusManager = BSANSociusManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanManagersManager = BSANManagersManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!, sanRestServices: sanJsonRestServicesImpl!)
        bsanPersonDataManager = BSANPersonDataManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanMobileRechargeManager = BSANMobileRechargeManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanTransfersManager = BSANTransfersManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!, sanRestServices: sanRestServicesImpl!)
        bsanCashWithdrawalManager = BSANCashWithdrawalManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanCesManager = BSANCesManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanSendMoneyManager = BSANSendMoneyManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanMifidManager = BSANMifidManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanOTPPushManager = BSANOTPPushManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanScaManager = BSANScaManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanPendingSolicitudesManager = BSANPendingSolicitudesManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanTimelineManager = BSANTimeLineManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanOnePlanManager = BSANOnePlanManagerImplementation(bsanDataProvider: bsanDataProvider!, sanSoapServices: sanSoapServicesImpl!)
        bsanLastLogonManager = BSANLastLogonManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanFavouriteTransfersManager = BSANFavouriteTransfersManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanRecoveryNoticesManager = BSANRecoveryNoticesManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanAviosManager = BSANAviosManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanBranchLocatorManager = BSANBranchLocatorManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanEcommerceManager = BSANEcommerceManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanSignBasicOperationManager = BSANSignBasicOperationManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanFintechManager = BSANFintechManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        bsanSubscriptionManager = BSANSubscriptionManagerImplementation(bsanDataProvider: bsanDataProvider!, sanRestServices: sanJsonRestServicesImpl!)
        do{
            //14725836
            let authenticateResponse = try bsanAuthManager!.authenticate(login: loginUser.rawValue, magic: "14725836", loginType: .N, isDemo: false)
            //            let authenticateResponse = try bsanAuthManager!.authenticate(login: loginUser.rawValue, magic: "33445566", loginType: .N, isDemo: false)
            
            if !authenticateResponse.isSuccess() {
                logTestError(errorMessage: try authenticateResponse.getErrorMessage(), function: #function)
                return
            }
            
            let gpResponse = try bsanPGManager!.loadGlobalPosition(onlyVisibleProducts: true, isPB: isPb)
            if shouldLoadGlobalPositionV2 {
                _ = try bsanPGManager!.loadGlobalPositionV2(onlyVisibleProducts: true, isPB: isPb)
            }

            let globalPositionDTO = try gpResponse.getResponseData()
            
            if globalPositionDTO == nil{
                XCTFail()
            }
        }
        catch let error as NSError {
            logTestError(errorMessage: error.localizedDescription, function: #function)
        }
    }
    
    func testloadGlobalPosition(){
        guard let sessionData = getSessionData() else {
            logTestError(errorMessage: "NO SESSION DATA", function: #function)
            XCTAssert(false)
            return
        }
        print("\n\n\(#function) :\n\(sessionData.globalPositionDTO)")
        XCTAssert(true)
        
    }
    
    func getSessionData() -> SessionData? {
        if let dataRepository = dataRepository, let sessionData = dataRepository.get(SessionData.self) {
            return sessionData
        }
        
        print("\nSessionData nil\n")
        return nil
    }
    
    func logTestException<T>(error: T?, function: String){
        if let error = error as? BSANException{
            logTestError(errorMessage: error.localizedDescription, function: function)
        }
        else if let error = error as? ParserException{
            logTestError(errorMessage: "PARSER_EXCEPTION: "+error.localizedDescription, function: function)
        }
        else if let error = error as? Error{
            logTestError(errorMessage: "EXCEPTION: "+error.localizedDescription, function: function)
        }
        else{
            logTestError(errorMessage: "ERROR DESCONOCIDO !!", function: function)
        }
    }
    
    func logTestSuccess<T>(result: T, function: String){
        print("\n\n💚 - \(function) :\n\(result)")
        XCTAssert(true)
    }
    
    func logTestError(errorMessage: String?, function: String){
        XCTFail("\n\n\(function) - 💔 ERROR : \((errorMessage ?? ""))\n")
    }
    
    func getElementForTesting<T>(orderInArray: Int, function: String) -> T?{
        guard let sessionData = getSessionData() else {
            logTestError(errorMessage: "NO SESSION DATA", function: function)
            return nil
        }
        
        guard let objects:[T] = getElements(sessionData) else {
            logTestError(errorMessage: "USER HAS NO OBJECTS (nil)", function: function)
            return nil
        }
        
        if objects.count == 0{
            logTestError(errorMessage: "USER HAS NO OBJECTS (0 loans)", function: function)
            return nil
        }
        
        if orderInArray >= objects.count{
            logTestError(errorMessage: "ORDER OVERFLOW : order = \(orderInArray), count = \(objects.count)", function: function)
            return nil
        }
        else{
            return objects[orderInArray]
        }
    }
    
    func getElements<T>(_ sessionData: SessionData) -> [T]?{
        fatalError()
    }
    
    func getResponseData<T>(response: BSANResponse<T>) throws -> T?{
        if let errorMessage = try response.getErrorMessage(){
            throw BSANException(errorMessage)
        }
        
        return try response.getResponseData()
    }
}
