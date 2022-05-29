
public class UserSegmentMatcher {
    public static func retrieveUserSegment(segmentsListDTO: SegmentsListDTO?, bdpCode: String?, comCode: String?) -> CommercialSegmentDTO? {
        guard let segmentsListDTO = segmentsListDTO else {
            return nil
        }
        guard let bdpCode = bdpCode else {
            return retrieveDefaultSegment(segmentsListDTO: segmentsListDTO)
        }
        var userCommercialSegment: CommercialSegmentDTO?
        for bdpSegment in segmentsListDTO.bdpSegments {
            if bdpCode == bdpSegment.bdpSegmentType {
                var defaultCommercialSegment: CommercialSegmentDTO?
                for commercialSegment in bdpSegment.commercialSegments {
                    if comCode == commercialSegment.commercialSegmentType {
                        userCommercialSegment = commercialSegment
                    } else if commercialSegment.commercialSegmentType == "Default" {
                        defaultCommercialSegment = commercialSegment
                    }
                }
                if userCommercialSegment == nil || comCode == nil {
                    userCommercialSegment = defaultCommercialSegment
                }
            }
        }
        if userCommercialSegment == nil {
            return retrieveDefaultSegment(segmentsListDTO: segmentsListDTO)
        } else {
            return userCommercialSegment
        }
    }
    
    public static func retrieveDefaultSegment(segmentsListDTO: SegmentsListDTO?) -> CommercialSegmentDTO? {
        guard let segmentsListDTO = segmentsListDTO else {
            return nil
        }
        var defaultCommercialSegment: CommercialSegmentDTO?
        for bdpSegment in segmentsListDTO.bdpSegments where bdpSegment.bdpSegmentType == "Default" {
            for commercialSegment in bdpSegment.commercialSegments where commercialSegment.commercialSegmentType == "Default" {
                defaultCommercialSegment = commercialSegment
            }
        }
        return defaultCommercialSegment;
    }
}
