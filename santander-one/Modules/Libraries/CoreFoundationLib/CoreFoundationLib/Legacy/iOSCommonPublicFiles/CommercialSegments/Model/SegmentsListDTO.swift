
public struct SegmentsListDTO {
    public let bdpSegments: [BDPSegmentDTO]
    public let xmlString: String?
    
    public init(bdpSegments: [BDPSegmentDTO], xmlString: String) {
        self.bdpSegments = bdpSegments
        self.xmlString = xmlString
    }
}
