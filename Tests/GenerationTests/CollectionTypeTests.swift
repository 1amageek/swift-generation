import Testing
import Foundation
@testable import Generation

@Suite("Collection Type Generable Conformances")
struct CollectionTypeTests {

    // MARK: - Array

    @Test("Array<String> round-trip")
    func arrayStringRoundTrip() throws {
        let original = ["a", "b", "c"]
        let content = original.generatedContent
        let restored = try [String](content)
        #expect(restored == original)
    }

    @Test("Array<Int> round-trip")
    func arrayIntRoundTrip() throws {
        let original = [1, 2, 3]
        let content = original.generatedContent
        let restored = try [Int](content)
        #expect(restored == original)
    }

    @Test("Empty array round-trip")
    func emptyArrayRoundTrip() throws {
        let original: [String] = []
        let content = original.generatedContent
        guard case .array(let elements) = content.kind else {
            Issue.record("Expected array kind"); return
        }
        #expect(elements.isEmpty)
    }

    @Test("Array generationSchema has array type")
    func arraySchema() {
        let schema = [String].generationSchema
        #expect(schema.debugDescription.contains("array"))
    }

    // MARK: - Optional

    @Test("Optional nil is .null")
    func optionalNil() {
        let value: String? = nil
        #expect(value.generatedContent.kind == .null)
    }

    @Test("Optional some preserves value")
    func optionalSome() throws {
        let value: String? = "hello"
        let content = value.generatedContent
        guard case .string(let s) = content.kind else {
            Issue.record("Expected string kind"); return
        }
        #expect(s == "hello")
    }

    @Test("Optional init from .null is nil")
    func optionalFromNull() throws {
        let content = GeneratedContent(kind: .null)
        let value: String? = try Optional<String>(content)
        #expect(value == nil)
    }

    @Test("Optional init from value is .some")
    func optionalFromValue() throws {
        let content = GeneratedContent(kind: .string("world"))
        let value: String? = try Optional<String>(content)
        #expect(value == "world")
    }

    @Test("Nested optionals")
    func nestedOptionals() {
        let doubleNil: String?? = nil
        #expect(doubleNil.generatedContent.kind == .null)

        let innerNil: String?? = .some(nil)
        #expect(innerNil.generatedContent.kind == .null)

        let value: String?? = .some(.some("nested"))
        guard case .string(let s) = value.generatedContent.kind else {
            Issue.record("Expected string kind"); return
        }
        #expect(s == "nested")
    }

    @Test("Optional array")
    func optionalArray() {
        let nilArray: [String]? = nil
        #expect(nilArray.generatedContent.kind == .null)

        let someArray: [String]? = ["x", "y"]
        guard case .array(let elements) = someArray.generatedContent.kind else {
            Issue.record("Expected array kind"); return
        }
        #expect(elements.count == 2)
    }

    // MARK: - Dictionary

    @Test("Dictionary<String, String> round-trip")
    func dictionaryStringRoundTrip() throws {
        let original: [String: String] = ["key": "value"]
        let content = original.generatedContent
        let restored = try [String: String](content)
        #expect(restored == original)
    }

    @Test("Dictionary<String, Int> round-trip")
    func dictionaryIntRoundTrip() throws {
        let original: [String: Int] = ["a": 1, "b": 2]
        let content = original.generatedContent
        let restored = try [String: Int](content)
        #expect(restored == original)
    }

    @Test("Empty dictionary round-trip")
    func emptyDictionaryRoundTrip() throws {
        let original: [String: String] = [:]
        let content = original.generatedContent
        guard case .structure(let props, _) = content.kind else {
            Issue.record("Expected structure kind"); return
        }
        #expect(props.isEmpty)
    }

    @Test("Dictionary generationSchema has dictionary type")
    func dictionarySchema() {
        let schema = [String: Int].generationSchema
        #expect(schema.debugDescription.contains("Dictionary") || schema.debugDescription.contains("dictionary"))
    }

    @Test("Dictionary from JSON string")
    func dictionaryFromJsonString() throws {
        let content = GeneratedContent(kind: .string("{\"x\": \"1\", \"y\": \"2\"}"))
        let dict = try [String: String](content)
        #expect(dict["x"] == "1")
        #expect(dict["y"] == "2")
    }
}
