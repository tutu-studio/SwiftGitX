# SwiftGitX

Welcome to SwiftGitX! 🎉

SwiftGitX provides modern Swift bindings to [libgit2](https://libgit2.org). It's designed to make working with Git in Swift easy and efficient. Plus, it fully supports the [Swift Package Manager](https://github.com/swiftlang/swift-package-manager) and has no external dependencies.

```swift
let url = URL(string: "https://github.com/ibrahimcetin/SwiftGitX.git")!
let repository = try await Repository.clone(from: url, to: URL(string: "/path/to/clone")!)

let latestCommit = try repository.HEAD.target as? Commit

let main = try repository.branch.get(named: "main")
let feature = try repository.branch.create(named: "feature", from: main)
try repository.switch(to: feature)
```

## Why Choose SwiftGitX?

SwiftGitX offers:

- Swift concurrency support: Take advantage of async/await for smooth, non-blocking Git operations.
- Throwing functions: Handle errors gracefully with Swift's error handling.
- Full SPM support: Easily integrate SwiftGitX into your projects.
- Intuitive design: A user-friendly API that's similar to the Git command line interface, making it easy to learn and use.

## Adding SwiftGitX to Your Project

To get started, just add SwiftGitX to your Package.swift file:
```swift
dependencies: [
    .package(url: "https://github.com/ibrahimcetin/SwiftGitX.git", from: "0.1.0"),
]
```

## Documentation

Check out online documentation [here](https://ibrahimcetin.github.io/SwiftGitX/documentation/swiftgitx/). With [Swift-Docc](https://www.swift.org/documentation/docc/), you can access everything seamlessly in Xcode.

## Building and Testing
SwiftGitX is easy to build and test. It requires only Swift, no additional system dependencies.
To build SwiftGitX, run:
```bash
swift build
```
To test SwiftGitX, run:
```bash
swift test
```

## Contributing

We welcome contributions! Whether you want to report a bug, request a feature, improve documentation, or add tests, we appreciate your help.

**For developers**, when contributing, please ensure to add appropriate tests and documentation to keep our project robust and well-documented.

---

Thank you for considering SwiftGitX for your project. I'm excited to see what you’ll build! 😊

---