//

protocol BizumMultimediaDataSourceProtocol: RestDataSource {
    func getMultimediaContacts(params: BizumGetMultimediaContactsParams) throws -> BSANResponse<BizumGetMultimediaContactsDTO>
    func getMultimediaContent(params: BizumGetMultimediaContentParams) throws -> BSANResponse<BizumGetMultimediaContentDTO>
    func sendImageText(params: BizumSendImageTextParams) throws -> BSANResponse<BizumTransferInfoDTO>
    func sendImageTextMulti(params: BizumSendImageTextMultiParams) throws -> BSANResponse<BizumTransferInfoDTO>
}
