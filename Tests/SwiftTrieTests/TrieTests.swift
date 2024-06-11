//
//  TrieTests.swift
//
//
//  Created by Terry Yiu on 6/9/24.
//

import XCTest
@testable import SwiftTrie

final class TrieTests: XCTestCase {

    func testFindPrefixedMatches() throws {
        let trie = Trie<String>()

        let keys = ["foobar", "food", "foo", "somethingelse", "duplicate", "duplicate", "first: second", "août"]
        keys.forEach {
            XCTAssertEqual(trie.insert(key: $0, value: $0), [$0])
        }

        let allResults = trie.find(key: "")
        XCTAssertEqual(Set(allResults), Set(keys))

        let fooResults = trie.find(key: "foo")
        XCTAssertEqual(fooResults.first, "foo")
        XCTAssertEqual(Set(fooResults), Set(["foobar", "food", "foo"]))

        let foodResults = trie.find(key: "food")
        XCTAssertEqual(foodResults, ["food"])

        let ooResults = trie.find(key: "oo")
        XCTAssertEqual(ooResults, [])

        let multipleWordsResults = trie.find(key: "second")
        XCTAssertEqual(multipleWordsResults, [])

        let notFoundResults = trie.find(key: "notfound")
        XCTAssertEqual(notFoundResults, [])

        let caseSensitiveResults = trie.find(key: "FOO")
        XCTAssertEqual(caseSensitiveResults, [])

        let diacriticResults = trie.find(key: "aout")
        XCTAssertEqual(diacriticResults, [])

        // Sanity check that the root node has children.
        XCTAssertTrue(trie.hasChildren)

        // Sanity check that the root node has no values.
        XCTAssertFalse(trie.hasValues)
    }

    func testFindNonPrefixedMatches() throws {
        let trie = Trie<String>()

        let keys = ["foobar", "food", "foo", "somethingelse", "duplicate", "duplicate", "first: second", "août"]
        keys.forEach {
            XCTAssertEqual(trie.insert(key: $0, value: $0, options: [.includeNonPrefixedMatches]), [$0])
        }

        let allResults = trie.find(key: "")
        XCTAssertEqual(Set(allResults), Set(keys))

        let fooResults = trie.find(key: "foo")
        XCTAssertEqual(fooResults.first, "foo")
        XCTAssertEqual(Set(fooResults), Set(["foobar", "food", "foo"]))

        let foodResults = trie.find(key: "food")
        XCTAssertEqual(foodResults, ["food"])

        let ooResults = trie.find(key: "oo")
        XCTAssertEqual(Set(ooResults), Set(["foobar", "food", "foo"]))

        let multipleWordsResults = trie.find(key: "second")
        XCTAssertEqual(multipleWordsResults, ["first: second"])

        let aResults = trie.find(key: "a")
        XCTAssertEqual(Set(aResults), Set(["foobar", "duplicate", "août"]))

        let notFoundResults = trie.find(key: "notfound")
        XCTAssertEqual(notFoundResults, [])

        let caseSensitiveResults = trie.find(key: "FOO")
        XCTAssertEqual(caseSensitiveResults, [])

        let diacriticResults = trie.find(key: "aout")
        XCTAssertEqual(diacriticResults, [])

        // Sanity check that the root node has children.
        XCTAssertTrue(trie.hasChildren)

        // Sanity check that the root node has no values.
        XCTAssertFalse(trie.hasValues)
    }

    func testFindCaseInsensitive() throws {
        let trie = Trie<String>()

        let key = "FoObAr"
        XCTAssertEqual(trie.insert(key: key, value: key, options: [.includeCaseInsensitiveMatches]), [key, "foobar"])

        let allResults = trie.find(key: "")
        XCTAssertEqual(Set(allResults), Set([key]))

        let fooResults = trie.find(key: "foo")
        XCTAssertEqual(fooResults, [key])

        // Sanity check that the root node has children.
        XCTAssertTrue(trie.hasChildren)

        // Sanity check that the root node has no values.
        XCTAssertFalse(trie.hasValues)
    }

    func testFindDiacriticInsensitive() throws {
        let trie = Trie<String>()

        let key = "Laïcité"
        XCTAssertEqual(
            trie.insert(key: key, value: key, options: [.includeDiacriticsInsensitiveMatches]),
            [key, "Laicite"]
        )

        let allResults = trie.find(key: "")
        XCTAssertEqual(Set(allResults), Set([key]))

        let laiciteResults = trie.find(key: "Laicite")
        XCTAssertEqual(laiciteResults, [key])

        // Sanity check that the root node has children.
        XCTAssertTrue(trie.hasChildren)

        // Sanity check that the root node has no values.
        XCTAssertFalse(trie.hasValues)
    }

    func testFindCaseAndDiacriticInsensitive() throws {
        let trie = Trie<String>()

        let key = "Laïcité"
        XCTAssertEqual(
            trie.insert(
                key: key,
                value: key,
                options: [.includeCaseInsensitiveMatches, .includeDiacriticsInsensitiveMatches]
            ),
            [key, "laïcité", "Laicite", "laicite"])

        let allResults = trie.find(key: "")
        XCTAssertEqual(Set(allResults), Set([key]))

        let laiciteResults = trie.find(key: "laicite")
        XCTAssertEqual(laiciteResults, [key])

        // Sanity check that the root node has children.
        XCTAssertTrue(trie.hasChildren)

        // Sanity check that the root node has no values.
        XCTAssertFalse(trie.hasValues)
    }

    func testRemove() {
        let trie = Trie<String>()

        let keys = ["FoObAr", "FOOD", "foo", "Sométhingëlse", "duplicate", "duplicate"]
        var insertedKeysMap = [String: [String]]()
        keys.forEach {
            insertedKeysMap[$0] = trie.insert(key: $0, value: $0,
                                              options: [
                                               .includeNonPrefixedMatches,
                                               .includeCaseInsensitiveMatches,
                                               .includeDiacriticsInsensitiveMatches
                                              ])
        }

        XCTAssertEqual(
            Set(insertedKeysMap.values.reduce([], +)),
            Set(keys + ["foobar", "food", "Somethingelse", "somethingelse", "sométhingëlse"])
        )

        insertedKeysMap.forEach { originalKey, insertedKeys in
            insertedKeys.forEach { insertedKey in
                trie.remove(key: insertedKey, value: originalKey)
            }
        }

        let allResults = trie.find(key: "")
        XCTAssertTrue(allResults.isEmpty)

        let fooResults = trie.find(key: "foo")
        XCTAssertTrue(fooResults.isEmpty)

        let foodResults = trie.find(key: "food")
        XCTAssertTrue(foodResults.isEmpty)

        let ooResults = trie.find(key: "oo")
        XCTAssertTrue(ooResults.isEmpty)

        let aResults = trie.find(key: "a")
        XCTAssertTrue(aResults.isEmpty)

        // Verify that removal of values from all the keys that were inserted in the trie previously
        // also resulted in the cleanup of the trie.
        XCTAssertFalse(trie.hasChildren)
        XCTAssertFalse(trie.hasValues)
    }

}
