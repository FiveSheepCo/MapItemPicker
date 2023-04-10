import MapKit

extension MKLocalSearchCompletion: Identifiable {
    public var id: String {
        "\(title)//\(subtitle)"
    }
}
