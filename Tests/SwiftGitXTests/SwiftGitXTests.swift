import SwiftGitX
import XCTest

class SwiftGitXTestCase: XCTestCase {
    static var directory: String {
        String(describing: Self.self)
    }

    override class func setUp() {
        super.setUp()

        // Initialize the SwiftGitX library
        XCTAssertNoThrow(try SwiftGitX.initialize())
    }

    override class func tearDown() {
        // Shutdown the SwiftGitX library
        XCTAssertNoThrow(try SwiftGitX.shutdown())

        // Remove the temporary directory for the tests
        try? FileManager.default.removeItem(at: Repository.testsDirectory.appending(component: directory))

        super.tearDown()
    }
}

final class SwiftGitXTests: SwiftGitXTestCase {
    func testSwiftGitXInitialize() throws {
        // Initialize the SwiftGitX library
        try SwiftGitX.initialize()

        // Shutdown the SwiftGitX library
        try SwiftGitX.shutdown()
    }

    func testVersion() throws {
        // Get the libgit2 version
        let version = SwiftGitX.libgit2Version

        // Check if the version is valid
        XCTAssertEqual(version, "1.8.0")
    }
}
