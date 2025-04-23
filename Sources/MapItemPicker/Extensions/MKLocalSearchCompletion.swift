import MapKit

extension MKLocalSearchCompletion: @retroactive Identifiable {
    public var id: String {
        "\(title)//\(subtitle)"
    }
}
