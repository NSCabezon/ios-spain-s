import CoreFoundationLib

public class RepositoryResponseSegmentMock: RepositoryResponse<CommercialSegmentEntity> {
    public override func isSuccess() -> Bool {
        return true
    }
}
