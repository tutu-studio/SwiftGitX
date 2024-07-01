import SwiftGitX
import XCTest

final class ConfigCollectionTests: SwiftGitXTestCase {
    func testConfigDefaultBranchName() {
        let repository = Repository.mock(named: "test-config-default-branch-name", in: Self.directory)

        // Set local default branch name
        repository.config.set("feature", forKey: "init.defaultBranch")

        XCTAssertEqual(repository.config.defaultBranchName, "feature")
    }

    func testConfigSet() {
        let repository = Repository.mock(named: "test-config-set", in: Self.directory)

        // Set local default branch name
        repository.config.set("develop", forKey: "init.defaultBranch")

        // Test if the default branch name is set
        XCTAssertEqual(repository.config.defaultBranchName, "develop")
        // Global default branch name should not be changed
        XCTAssertEqual(Repository.config.defaultBranchName, "main")
    }

    func testConfigString() {
        let repository = Repository.mock(named: "test-config-string", in: Self.directory)

        // Set local user name and email
        repository.config.set("İbrahim Çetin", forKey: "user.name")
        repository.config.set("mail@ibrahimcetin.dev", forKey: "user.email")

        XCTAssertEqual(repository.config.string(forKey: "user.name"), "İbrahim Çetin")
        XCTAssertEqual(repository.config.string(forKey: "user.email"), "mail@ibrahimcetin.dev")
    }

    func testConfigGlobalString() {
        // Get global default branch name
        XCTAssertEqual(Repository.config.string(forKey: "init.defaultBranch"), "main")
    }
}
