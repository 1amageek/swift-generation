import Testing
import Foundation
@testable import SwiftGeneration

@Suite("GeneratedContent")
struct GeneratedContentTests {

    @Test("String creation and text access")
    func stringCreation() {
        let content = GeneratedContent("Hello, world!")
        #expect(content.text == "Hello, world!")
    }

    @Test("Empty string creation")
    func emptyStringCreation() {
        let content = GeneratedContent("")
        #expect(content.text.isEmpty)
    }

    @Test("Kind-based creation")
    func kindBasedCreation() {
        let string = GeneratedContent(kind: .string("abc"))
        #expect(string.text == "abc")

        let number = GeneratedContent(kind: .number(42))
        #expect(number.text == "42")

        let bool = GeneratedContent(kind: .bool(true))
        #expect(bool.text == "true")

        let null = GeneratedContent(kind: .null)
        #expect(null.text == "null")
    }

    @Test("JSON parsing with simple object")
    func jsonParsing() throws {
        let json = """
        {"name": "Alice", "age": 30}
        """
        let content = try GeneratedContent(json: json)
        let props = try content.properties()
        #expect(props["name"]?.text == "Alice")
        #expect(props["age"]?.text == "30")
    }

    @Test("JSON parsing with nested structure")
    func nestedJsonParsing() throws {
        let json = """
        {"user": {"profile": {"name": "Bob"}}}
        """
        let content = try GeneratedContent(json: json)
        let props = try content.properties()
        let userProps = try props["user"]?.properties()
        let profileProps = try userProps?["profile"]?.properties()
        #expect(profileProps?["name"]?.text == "Bob")
    }

    @Test("JSON parsing with array")
    func jsonArrayParsing() throws {
        let json = """
        {"tags": ["swift", "generation"]}
        """
        let content = try GeneratedContent(json: json)
        let props = try content.properties()
        let tags = try props["tags"]?.elements()
        #expect(tags?.count == 2)
        #expect(tags?[0].text == "swift")
        #expect(tags?[1].text == "generation")
    }

    @Test("JSON parsing with boolean and null")
    func jsonBoolAndNull() throws {
        let json = """
        {"active": true, "deleted": false, "metadata": null}
        """
        let content = try GeneratedContent(json: json)
        let props = try content.properties()
        #expect(props["active"]?.text == "true")
        #expect(props["deleted"]?.text == "false")
        #expect(props["metadata"]?.kind == .null)
    }

    @Test("Structure kind preserves key order")
    func keyOrderPreservation() {
        let content = GeneratedContent(
            kind: .structure(
                properties: ["z": GeneratedContent("1"), "a": GeneratedContent("2")],
                orderedKeys: ["z", "a"]
            )
        )
        if case .structure(_, let keys) = content.kind {
            #expect(keys == ["z", "a"])
        } else {
            Issue.record("Expected structure kind")
        }
    }

    @Test("Value extraction with typed access")
    func typedValueAccess() throws {
        let json = """
        {"name": "Test", "count": 5}
        """
        let content = try GeneratedContent(json: json)
        let name: String = try content.value(String.self, forProperty: "name")
        #expect(name == "Test")
    }
}
