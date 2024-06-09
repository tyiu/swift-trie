[![Unit Tests](https://github.com/tyiu/swift-trie/actions/workflows/unit.yml/badge.svg)](https://github.com/tyiu/swift-trie/actions/workflows/unit.yml) [![SwiftLint](https://github.com/tyiu/swift-trie/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/tyiu/swift-trie/actions/workflows/swiftlint.yml) [![Docs](https://github.com/tyiu/swift-trie/actions/workflows/docs.yml/badge.svg)](https://github.com/tyiu/swift-trie/actions/workflows/docs.yml)

# SwiftTrie

A Swift package that provides a [Trie](https://en.wikipedia.org/wiki/Trie) data structure that allow efficient searches of values that map from prefixed keys or non-prefixed key substrings.

## Minimum Requirements

- Swift 5.8

## Installation

SwiftTrie can be integrated as an Xcode project target or a Swift package target.

### Xcode Project Target

1. Go to `File` -> `Add Package Dependencies`.
2. Type https://github.com/tyiu/swift-trie.git into the search field.
3. Select `swift-trie` from the search results.
4. Select `Up to Next Major Version` starting from the latest release as the dependency rule.
5. Ensure your project is selected next to `Add to Project`.
6. Click `Add Package`.
7. On the package product dialog, add `SwiftTrie` to your target and click `Add Package`.

### Swift Package Target

In your `Package.swift` file:
1. Add the SwiftTrie package dependency to https://github.com/tyiu/swift-trie.git
2. Add `SwiftTrie` as a dependency on the targets that need to use the SDK.

```swift
let package = Package(
    // ...
    dependencies: [
        // ...
        .package(url: "https://github.com/tyiu/swift-trie.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target(
            // ...
            dependencies: ["SwiftTrie"]
        ),
        .testTarget(
            // ...
            dependencies: ["SwiftTrie"]
        )
    ]
)
```

## Usage

See [TrieTests.swift](Tests/SwiftTrieTests/TrieTests.swift) for an example of how to use SwiftTrie.
