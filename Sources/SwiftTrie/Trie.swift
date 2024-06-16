//
//  Trie.swift
//
//
//  Created by Terry Yiu on 6/9/24.
//

import Foundation
import OrderedCollections

/// Trie is a tree data structure of all the substring permutations of a collection of strings
/// optimized for searching for values of type V.
///
/// Each node in the tree can have child nodes.
/// Each node represents a single character in substrings,
/// and each of its child nodes represent the subsequent character in those substrings.
///
/// A node that has no children mean that there are no substrings
/// with any additional characters beyond the branch of letters leading up to that node.
///
/// A node that has values mean that there are strings that end in the character represented by the node
/// and contain the substring represented by the branch of letters leading up to that node.
///
/// See the article on [Trie](https://en.wikipedia.org/wiki/Trie) on Wikipedia.
public class Trie<V: Hashable> {
    private var children = OrderedDictionary<Character, Trie>()

    /// Separate exact matches from strict substrings so that exact matches appear first in returned results.
    private var exactMatchValues = OrderedSet<V>()
    private var substringMatchValues = OrderedSet<V>()

    private var parent: Trie?

    var hasChildren: Bool {
        return !self.children.isEmpty
    }

    var hasValues: Bool {
        return !self.exactMatchValues.isEmpty || !self.substringMatchValues.isEmpty
    }

    public init() { }
}

/// The transformation options that can be applied to the original key when inserting a value into a trie
/// as additional keys that map to the value.
public struct TrieInsertionOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Inserts all permutations of non-prefixed substring versions of the original key.
    public static let includeNonPrefixedMatches = TrieInsertionOptions(rawValue: 1 << 0)

    /// Inserts the localized lowercase version of the original key.
    public static let includeCaseInsensitiveMatches = TrieInsertionOptions(rawValue: 1 << 1)

    /// Inserts the original key with all diactritics removed.
    public static let includeDiacriticsInsensitiveMatches = TrieInsertionOptions(rawValue: 1 << 2)
}

public extension Trie {
    /// Finds the branch that matches the specified key and returns the values from all of its descendant nodes.
    /// Note: If `key` is an empty string, all values are returned.
    /// - Parameters:
    ///   - key: The key to find in the trie.
    /// - Returns: The values that are mapped from matches of `key`.
    func find(key: String) -> [V] {
        var currentNode = self

        // Find branch with matching prefix.
        for char in key {
            if let child = currentNode.children[char] {
                currentNode = child
            } else {
                return []
            }
        }

        // Perform breadth-first search from matching branch and collect values from all descendants.
        var substringMatches = OrderedSet<V>(currentNode.substringMatchValues)
        var queue = Array(currentNode.children.values)

        while !queue.isEmpty {
            let node = queue.removeFirst()
            substringMatches.formUnion(node.exactMatchValues)
            substringMatches.formUnion(node.substringMatchValues)
            queue.append(contentsOf: node.children.values)
        }

        // Prioritize exact matches to be returned first,
        // and then remove exact matches from the set of partial substring matches that are appended afterward.
        return Array(currentNode.exactMatchValues) + (substringMatches.subtracting(currentNode.exactMatchValues))
    }

    // swiftlint:disable cyclomatic_complexity
    /// Inserts a value into this trie for the specified key.
    /// This function stores all substring endings of the key, not only the key itself.
    /// Runtime performance is O(n^2) and storage cost is O(n), where n is the number of characters in the key.
    /// Note: If `key` is an empty string, this operation is effectively a no-op.
    /// - Parameters:
    ///   - key: The key to insert that maps to `value`.
    ///   - value: The value that is mapped from `key`.
    ///   - options: The options to apply different transformations to `key` for additional insertion.
    /// - Returns: The list of whole keys that were inserted that map to `value`.
    func insert(key originalKey: String, value: V, options: TrieInsertionOptions = []) -> [String] {
        let includeNonPrefixedMatches = options.contains(.includeNonPrefixedMatches)
        let includeCaseInsensitiveMatches = options.contains(.includeCaseInsensitiveMatches)
        let includeDiacriticsInsensitiveMatches = options.contains(.includeDiacriticsInsensitiveMatches)

        var keys = [originalKey]
        if includeCaseInsensitiveMatches {
            let localizedLowercase = originalKey.localizedLowercase
            if localizedLowercase != originalKey {
                keys.append(localizedLowercase)
            }
        }
        if includeDiacriticsInsensitiveMatches,
           let keyWithoutDiacritics = originalKey.applyingTransform(.stripDiacritics, reverse: false),
           keyWithoutDiacritics != originalKey {
            keys.append(keyWithoutDiacritics)

            if includeCaseInsensitiveMatches {
                let localizedLowercaseWithoutDiacritics = keyWithoutDiacritics.localizedLowercase
                if localizedLowercaseWithoutDiacritics != originalKey {
                    keys.append(localizedLowercaseWithoutDiacritics)
                }
            }
        }

        for key in keys {
            // Create root branches for each character of the key to enable substring searches
            // instead of only just prefix searches.
            // Hence the nested loop.
            for keyIndex in 0..<key.count {
                var currentNode = self

                // Find branch with matching prefix.
                for char in key[key.index(key.startIndex, offsetBy: keyIndex)...] {
                    if let child = currentNode.children[char] {
                        currentNode = child
                    } else {
                        let child = Trie()
                        child.parent = currentNode
                        currentNode.children[char] = child
                        currentNode = child
                    }
                }

                if keyIndex == 0 {
                    currentNode.exactMatchValues.append(value)

                    // If includeNonPrefixedMatches is true, the first character of the key can be the only root branch
                    // and we terminate the loop early.
                    if !includeNonPrefixedMatches {
                        break
                    }
                } else {
                    currentNode.substringMatchValues.append(value)
                }
            }
        }

        return keys
    }
    // swiftlint:enable cyclomatic_complexity

    /// Removes a value from this trie for the specified key.
    /// - Parameters:
    ///   - key: The key to remove.
    ///   - value: The value to remove.
    func remove(key: String, value: V) {
        for keyIndex in 0..<key.count {
            var currentNode = self

            var foundLeafNode = true

            // Find branch with matching prefix.
            for keySubIndex in keyIndex..<key.count {
                let char = key[key.index(key.startIndex, offsetBy: keySubIndex)]

                if let child = currentNode.children[char] {
                    currentNode = child
                } else {
                    foundLeafNode = false
                    break
                }
            }

            if foundLeafNode {
                currentNode.exactMatchValues.remove(value)
                currentNode.substringMatchValues.remove(value)

                // Clean up the tree if this leaf node no longer holds values or children.
                for keySubIndex in (keyIndex..<key.count).reversed() {
                    if let parent = currentNode.parent, !currentNode.hasValues && !currentNode.hasChildren {
                        currentNode = parent
                        let char = key[key.index(key.startIndex, offsetBy: keySubIndex)]
                        currentNode.children.removeValue(forKey: char)
                    }
                }
            }
        }
    }
}
