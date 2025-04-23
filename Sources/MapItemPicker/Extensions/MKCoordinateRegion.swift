import MapKit

extension MKCoordinateRegion: @retroactive Equatable
{
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool
    {
        if lhs.center.latitude != rhs.center.latitude || lhs.center.longitude != rhs.center.longitude
        {
            return false
        }
        if lhs.span.latitudeDelta != rhs.span.latitudeDelta || lhs.span.longitudeDelta != rhs.span.longitudeDelta
        {
            return false
        }
        return true
    }
    
    static var unitedStates: MKCoordinateRegion {
        .init(
            center: .init(latitude: 38, longitude: -100),
            span: .init(latitudeDelta: 60, longitudeDelta: 60)
        )
    }
}
