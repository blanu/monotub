import XCTest
@testable import monotub

final class monotubTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(monotub().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
