import SwiftGitX
import XCTest

final class ConfigCollectionTests: SwiftGitXTestCase {
    func testConfigDefaultBranchName() {
        let repository = Repository.mock(named: "test-config-default-branch-name", in: Self.directory)

        XCTAssertEqual(repository.config.defaultBranchName, "main")
    }

    func testConfigSet() {
        let repository = Repository.mock(named: "test-config-set", in: Self.directory)

        repository.config.set("develop", forKey: "init.defaultBranch")

        XCTAssertEqual(repository.config.defaultBranchName, "develop")
    }

    func testConfigString() {
        let repository = Repository.mock(named: "test-config-string", in: Self.directory)

        repository.config.set("İbrahim Çetin", forKey: "user.name")
        repository.config.set("mail@ibrahimcetin.dev", forKey: "user.email")

        XCTAssertEqual(repository.config.string(forKey: "user.name"), "İbrahim Çetin")
        XCTAssertEqual(repository.config.string(forKey: "user.email"), "mail@ibrahimcetin.dev")
    }
}
