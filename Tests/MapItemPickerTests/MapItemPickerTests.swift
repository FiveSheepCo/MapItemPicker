import XCTest
@testable import MapItemPicker

final class MapItemPickerTests: XCTestCase {
    func testMapItemCategoryImagesExist() {
        for category in MapItemCategory.allCases where UIImage(systemName: category.imageName) == nil {
            XCTFail("Category Image `\(category.imageName)` for `\(category.name)` does not exist for \(UIDevice.current.systemVersion)")
        }
        XCTAssertTrue(true)
    }
}
