import SwiftGitX
import XCTest

final class BranchCollectionTests: SwiftGitXTestCase {
    func testBranchLookup() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-branch-lookup", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Lookup the branch
        let lookupBranch = try repository.branch.get(named: "main", type: .local)

        // Check the branch
        XCTAssertEqual(lookupBranch.name, "main")
        XCTAssertEqual(lookupBranch.fullName, "refs/heads/main")
        XCTAssertEqual(lookupBranch.target.id, commit.id)
    }

    func testBranchLookupSubscript() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-branch-lookup-subscript", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Lookup the branch
        let lookupBranch = try XCTUnwrap(repository.branch["main"])
        let lookupBranchLocal = try XCTUnwrap(repository.branch["main", type: .local])

        XCTAssertEqual(lookupBranch, lookupBranchLocal)

        // Check the branch
        XCTAssertEqual(lookupBranch.name, "main")
        XCTAssertEqual(lookupBranch.fullName, "refs/heads/main")
        XCTAssertEqual(lookupBranch.target.id, commit.id)

        // Lookup remote branch (should be nil)
        let lookupBranchRemote = repository.branch["main", type: .remote]
        XCTAssertNil(lookupBranchRemote)
    }

    func testBranchCurrent() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-branch-current", in: Self.directory)

        // Create mock commit
        try repository.mockCommit()

        // Get the current branch
        let currentBranch = try XCTUnwrap(repository.branch.current)

        // Check the current branch
        XCTAssertEqual(currentBranch.name, "main")
        XCTAssertEqual(currentBranch.fullName, "refs/heads/main")
        XCTAssertEqual(currentBranch.type, .local)
    }

    func testBranchCreate() throws {
        let repository = Repository.mock(named: "test-branch-create", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Create a new branch
        let branch = try repository.branch.create(named: "develop", target: commit)

        // Check the branch
        XCTAssertEqual(branch.name, "develop")
        XCTAssertEqual(branch.fullName, "refs/heads/develop")
        XCTAssertEqual(branch.target.id, commit.id)
        XCTAssertEqual(branch.type, .local)
    }

    func testBranchCreateFrom() throws {
        let repository = Repository.mock(named: "test-branch-create-from", in: Self.directory)

        // Create mock commit
        try repository.mockCommit()

        // Get the main branch
        let mainBranch = try repository.branch.get(named: "main")

        // Create a new branch
        let newBranch = try repository.branch.create(named: "develop", from: mainBranch)

        // Check the branch
        XCTAssertEqual(newBranch.name, "develop")
        XCTAssertEqual(newBranch.fullName, "refs/heads/develop")
        XCTAssertEqual(newBranch.target.id, mainBranch.target.id)
        XCTAssertEqual(newBranch.type, .local)
    }

    func testBranchDelete() throws {
        let repository = Repository.mock(named: "test-branch-delete", in: Self.directory)

        // Create mock commit
        let commit: Commit = try repository.mockCommit()

        // Create a new branch
        let branch = try repository.branch.create(named: "develop", target: commit)

        // Delete the branch
        XCTAssertNoThrow(try repository.branch.delete(branch))

        // Check the branch
        XCTAssertThrowsError(try repository.branch.get(named: "develop"))
        XCTAssertNil(repository.branch["develop"])

        // Check the current branch
        XCTAssertEqual(try repository.branch.current.name, "main")
    }

    func testBranchDeleteCurrentFailure() throws {
        let repository = Repository.mock(named: "test-branch-delete-current-failure", in: Self.directory)

        // Create mock commit
        try repository.mockCommit()

        // Get the main branch (current branch)
        let mainBranch = try repository.branch.get(named: "main")

        // Delete the branch
        XCTAssertThrowsError(try repository.branch.delete(mainBranch))
    }

    func testBranchRename() throws {
        let repository = Repository.mock(named: "test-branch-rename", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Create a new branch
        let branch = try repository.branch.create(named: "develop", target: commit)

        // Rename the branch
        let newBranch = try repository.branch.rename(branch, to: "feature")

        // Check the branch
        XCTAssertEqual(newBranch.name, "feature")
        XCTAssertEqual(newBranch.fullName, "refs/heads/feature")
        XCTAssertEqual(newBranch.target.id, commit.id)
        XCTAssertEqual(newBranch.type, .local)

        // Check the old branch
        XCTAssertThrowsError(try repository.branch.get(named: "develop"))
        XCTAssertNil(repository.branch["develop"])
    }

    func testBranchSequenceLocal() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-branch-sequence-local", in: Self.directory)

        // Get the local branches
        // (must be empty because the main branch is unborn)
        let localBranchesEmpty = Array(repository.branch.local)

        // Check empty branches
        XCTAssertEqual(localBranchesEmpty, [])

        // Create mock commit
        let commit = try repository.mockCommit()

        // Create some new branches
        let newBranchNames = ["other-branch", "another-branch", "one-more-branch", "last-branch"]
        for name in newBranchNames {
            try repository.branch.create(named: name, target: commit)
        }

        // Get the local branches
        let localBranches = Array(repository.branch.local)

        // Check the local branches count (including the main branch)
        XCTAssertEqual(localBranches.count, 5)

        // Check the local branches
        let allBranchNames = repository.branch.local.map(\.name)
        for name in allBranchNames {
            let branch = try repository.branch.get(named: name, type: .local)
            XCTAssertTrue(localBranches.contains(branch))
        }
    }

    func testBranchListLocal() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-branch-list-local", in: Self.directory)

        // Get the local branches
        // (must be empty because the main branch is unborn)
        let branches = try repository.branch.list(.local)

        // Check empty branches
        XCTAssertEqual(branches, [])

        // Create a new commit
        let commit = try repository.mockCommit()

        // Create some new branches
        let newBranchNames = ["other-branch", "another-branch", "one-more-branch", "last-branch"]

        for name in newBranchNames {
            try repository.branch.create(named: name, target: commit)
        }

        // Get the local branches
        let localBranches = try repository.branch.list(.local)

        // Check the local branches count
        XCTAssertEqual(localBranches.count, 5)

        // Check the local branches (we need to check main branch too)
        let allBranchNames = localBranches.map(\.name)
        for name in allBranchNames {
            let branch = try repository.branch.get(named: name, type: .local)
            XCTAssertTrue(localBranches.contains(branch))
        }
    }

    func testBranchUpstream() async throws {
        // Create a mock repository at the temporary directory
        let source = URL(string: "https://github.com/ibrahimcetin/SwiftGitX.git")!
        let directory = Repository.mockDirectory(named: "test-branch-upstream", in: Self.directory)
        let repository = try await Repository.clone(from: source, to: directory)

        // Get the upstream branch of the current branch
        let upstreamBranch = try XCTUnwrap(repository.branch.current.upstream as? Branch)

        // Check the upstream branch
        XCTAssertEqual(upstreamBranch.name, "origin/main")
        XCTAssertEqual(upstreamBranch.fullName, "refs/remotes/origin/main")
        XCTAssertEqual(upstreamBranch.type, .remote)
    }

    func testBranchSetUpstream() async throws {
        // Create a mock repository at the temporary directory
        let source = URL(string: "https://github.com/ibrahimcetin/SwiftGitX.git")!
        let directory = Repository.mockDirectory(named: "test-branch-set-upstream", in: Self.directory)
        let repository = try await Repository.clone(from: source, to: directory)

        // Unset the existing upstream branch
        try repository.branch.setUpstream(to: nil)
        // Be sure that the upstream branch is unset
        try XCTAssertNil(repository.branch.current.upstream)

        // Set the upstream branch
        try repository.branch.setUpstream(to: repository.branch.get(named: "origin/main"))

        // Check if the upstream branch is set
        let upstreamBranch = try XCTUnwrap(repository.branch.current.upstream as? Branch)
        XCTAssertEqual(upstreamBranch.name, "origin/main")
        XCTAssertEqual(upstreamBranch.fullName, "refs/remotes/origin/main")
    }

    func testBranchUnsetUpstream() async throws {
        // Create a mock repository at the temporary directory
        let source = URL(string: "https://github.com/ibrahimcetin/SwiftGitX.git")!
        let directory = Repository.mockDirectory(named: "test-branch-unset-upstream", in: Self.directory)
        let repository = try await Repository.clone(from: source, to: directory)

        // Be sure that the upstream branch is set
        try XCTAssertNotNil(repository.branch.current.upstream)

        // Unset the upstream branch
        try repository.branch.setUpstream(to: nil)

        // Check if the upstream branch is unset
        try XCTAssertNil(repository.branch.current.upstream)
    }
}
