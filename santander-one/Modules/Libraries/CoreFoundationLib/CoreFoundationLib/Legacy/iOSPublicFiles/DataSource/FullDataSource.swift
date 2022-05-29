struct FullClientSavedData: Codable {
    let date: Date?
    let data: String
    let base: String
}

open class FullDataSource<T, P: Parser>: NetDataSource<T, P> where P.Parseable == T  {
    let fileClient: FileClient
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient, parser: P, parameters: BaseDataSourceParameters) {
        self.fileClient = fileClient
        super.init(parser: parser, parameters: parameters, assetsClient: assetsClient, netClient: netClient)
    }
    
    private func loadFromFile(_ baseUrl: String?) {
        let path = self.buildLocalizedLocalPath()
        guard let savedDataString = self.fileClient.get(path) else {
            return
        }
        guard let jsonData = savedDataString.data(using: .utf8) else {
            return
        }
        let jsonDecoder = JSONDecoder()
        do {
            let savedDataEntity = try jsonDecoder.decode(FullClientSavedData.self, from: jsonData)
            guard baseUrl == nil || savedDataEntity.base == baseUrl else {
                return
            }
            let responseDTO = self.parser.serialize(savedDataEntity.data)
            if baseUrl == nil {
                self.lastUpdated = savedDataEntity.date
                self.responseDate = self.lastUpdated
            }
            self.dto = responseDTO
        } catch {}
    }
    
    open func storeOnFile(_ baseUrl: String) {
        if let dto = self.dto, let fileString = self.parser.deserialize(dto) {
            let path = self.buildLocalizedLocalPath()
            let jsonEncoder = JSONEncoder()
            let savedDataEntity = FullClientSavedData(date: self.responseDate, data: fileString, base: baseUrl)
            do {
                let jsonData = try jsonEncoder.encode(savedDataEntity)
                guard let savedDataString = String(data: jsonData, encoding: .utf8) else {
                    return
                }
                try self.fileClient.set(savedDataString, path: path)
            } catch {}
        }
    }
    
    public override func getType() -> T? {
        if self.dto == nil {
            self.loadFromFile(nil)
            if self.dto == nil {
                self.loadFromAssets(baseURL: defaultAssetsPath)
            }
        }
        return self.dto
    }
    
    public override func load(baseUrl: String, publicLanguage: PublicLanguage?) {
        self.dto = nil
        self.lastUpdated = nil
        self.responseDate = nil
        self.publicLanguage = publicLanguage
        if self.isAssetsPath(baseUrl) {
            self.loadFromAssets(baseURL: baseUrl)
        } else {
            self.loadFromFile(baseUrl)
            if self.dto == nil {
                self.loadFromAssets(baseURL: defaultAssetsPath)
            }
            self.loadOnline(baseUrl: baseUrl)
        }
        self.storeOnFile(baseUrl)
    }
    
    public override func remove() {
        super.remove()
        let path = buildLocalizedLocalPath()
        self.fileClient.remove(path: path)
    }
}
