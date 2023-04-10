import MapKit

public extension MKMapRect {
    init(_ region: MKCoordinateRegion) {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        self.init(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
    init(center: MKMapPoint, size: MKMapSize) {
        self.init(
            origin: .init(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2
            ),
            size: size
        )
    }
    
    init?(bestFor coordinates: [CLLocationCoordinate2D]) {
        self.init(bestFor: coordinates.map(MKMapPoint.init))
    }
    
    init?(bestFor points: [MKMapPoint]) {
        guard !points.isEmpty else { return nil }
        
        var points = points
        let length: CGFloat = points.count == 1 ? 100000 : 5000
        let mapSize = MKMapSize(width: length, height: length)
        var rect = MKMapRect(
            center: points.removeFirst(),
            size: mapSize
        )
        
        for point in points {
            rect = rect.union(
                .init(
                    center: point,
                    size: mapSize
                )
            )
        }
        
        self = rect
    }
}
