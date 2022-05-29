open class NetDataSource<T, P: Parser> where P.Parseable == T {
    public var dto: T? {
        get {
            return threadSafeDto.value
        }
        set {
            self.threadSafeDto.value = newValue
        }
    }
    var responseDate: Date?
    var lastUpdated: Date?
    public var parser: P
    public var publicLanguage: PublicLanguage?
    public let parameters: BaseDataSourceParameters
    public let assetsClient: AssetsClient
    let netClient: NetClient
    let assetsPaths = ["assets/", "assetsLocal/"]
    let defaultAssetsPath = "assets/default"
    private let threadSafeDto: ThreadSafePropertyOptional<T>

    public init(parser: P, parameters: BaseDataSourceParameters, assetsClient: AssetsClient, netClient: NetClient) {
        self.parser = parser
        self.parameters = parameters
        self.assetsClient = assetsClient
        self.netClient = netClient
        self.threadSafeDto = ThreadSafePropertyOptional<T>()
    }
    
    func loadOnline(baseUrl: String) {
        let path = self.buildLocalizedPath(baseURL: baseUrl)
        let response = self.netClient.loadURL(path, date: self.lastUpdated)
        if case .loaded(let response, let date) = response,
            let responseDTO = self.parser.serialize(response) {
            self.dto = responseDTO
            self.responseDate = date
        }
    }
    
    public func getType() -> T? {
        if let dto = self.dto {
            return dto
        } else {
            self.loadFromAssets(baseURL: self.defaultAssetsPath)
            return self.dto
        }
    }
    
    public func load(baseUrl: String, publicLanguage: PublicLanguage?) {
        self.dto = nil
        self.publicLanguage = publicLanguage
        if self.isAssetsPath(baseUrl) {
            self.loadFromAssets(baseURL: baseUrl)
        } else {
            self.loadFromAssets(baseURL: self.defaultAssetsPath)
            self.loadOnline(baseUrl: baseUrl)
        }
    }
    
    public func remove() {}
    
    func isAssetsPath(_ baseUrl: String) -> Bool {
        let found = self.assetsPaths.first {
            return baseUrl.contains($0)
        } != nil
        return found
    }
}

extension NetDataSource: BaseDataSource {
}

extension NetDataSource: DataSourcePublic {
}
