
public class BizumMultimediaDataSource {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let basePath = "/"
    private let getMultimediaPath = "api/v2/bizum-txt-img/"
    private let getMultimediaContactsServiceName = "get-multimedia-users"
    private let getMultimediaContentServiceName = "get-image-text"
    private let getSendImageTextServiceName = "send-image-text"
    private let getMultimediaMultiPath = "api/v2/bizum-txt-img/"
    private let getSendImageTextMultiServiceName = "send-image-text-multi"
    private let headers = ["X-Santander-Channel" : "RML"]
    
    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
}

extension BizumMultimediaDataSource: BizumMultimediaDataSourceProtocol {
    
    /// Get bizum contacs multimedia capabilities
    /// - Parameter params: BizumGetMultimediaContactsParams data
    func getMultimediaContacts(params: BizumGetMultimediaContactsParams) throws -> BSANResponse<BizumGetMultimediaContactsDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.getMultimediaPath + self.getMultimediaContactsServiceName
        return try self.executeRestCall(
            serviceName: self.getMultimediaContactsServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }

    /// Get bizum multimedia content
    /// - Parameter params:

    func getMultimediaContent(params: BizumGetMultimediaContentParams) throws -> BSANResponse<BizumGetMultimediaContentDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.getMultimediaPath + self.getMultimediaContentServiceName
            return try self.executeRestCall(
                serviceName: self.getMultimediaContactsServiceName,
                serviceUrl: url,
                params: params,
                contentType: ContentType.json,
                requestType: .post,
                headers: headers,
                responseEncoding: .utf8)
    }

    /// Upload image and text attachements to a bizum transfer operation
    /// - Parameter params: BizumSendImageTextParams data
    func sendImageText(params: BizumSendImageTextParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else { return BSANErrorResponse(nil) }
        let url = source + self.basePath + self.getMultimediaPath + self.getSendImageTextServiceName
        return try self.executeRestCall(
            serviceName: self.getSendImageTextServiceName,
            serviceUrl: url,
            params: params,
            removesEscapeCharacters: true,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8
        )
    }
    
    /// Upload image and text attachements to a bizum transfer operation to multiple destinations
    /// - Parameter params: BizumSendImageTextParams data
    func sendImageTextMulti(params: BizumSendImageTextMultiParams) throws -> BSANResponse<BizumTransferInfoDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.getMultimediaMultiPath + self.getSendImageTextMultiServiceName
        return try self.executeRestCall(
            serviceName: self.getSendImageTextMultiServiceName,
            serviceUrl: url,
            params: params,
            contentType: ContentType.json,
            requestType: .post,
            headers: headers,
            responseEncoding: .utf8)
    }
}
