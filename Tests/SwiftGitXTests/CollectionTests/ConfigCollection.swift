import SwiftGitX
import XCTest

final class ConfigCollectionTests: SwiftGitXTestCase {
    func testConfigDefaultBranchName() {
        let repository = Repository.mock(named: "test-config-default-branch-name", in: Self.directory)

        XCTAssertEqual(repository.config.defaultBranchName, "main")
    }
}
