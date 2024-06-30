//
//  RepositoryPerformanceTests.swift
//
//
//  Created by İbrahim Çetin on 21.04.2024.
//

import SwiftGitX
import XCTest

final class RepositoryPerformanceTests: SwiftGitXTestCase {
    private let options: XCTMeasureOptions = {
        let options = XCTMeasureOptions.default

        options.invocationOptions = [.manuallyStart, .manuallyStop]
        options.iterationCount = 10

        return options
    }()

    func testPerformanceAdd() throws {
        // Create a repository
        let repository = Repository.mock(named: "test-performance-add", in: Self.directory)

        measure(options: options) {
            do {
                let file = try repository.mockFile(named: UUID().uuidString)

                // Measure the time it takes to add a file
                startMeasuring()
                try repository.add(file: file)
                stopMeasuring()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testPerformanceCommit() throws {
        // Create a repository
        let repository = Repository.mock(named: "test-performance-commit", in: Self.directory)

        measure(options: options) {
            do {
                // Add a file to the index
                try repository.add(file: repository.mockFile(named: UUID().uuidString))

                // Measure the time it takes to commit the file
                startMeasuring()
                try repository.commit(message: "Commit message")
                stopMeasuring()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
