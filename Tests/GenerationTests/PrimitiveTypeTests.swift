import Testing
import Foundation
@testable import Generation

@Suite("Primitive Type Generable Conformances")
struct PrimitiveTypeTests {

    // MARK: - String

    @Test("String round-trip")
    func stringRoundTrip() throws {
        let original = "hello"
        let content = original.generatedContent
        let restored = try String(content)
        #expect(restored == original)
    }

    @Test("String kind is .string")
    func stringKind() {
        let content = "test".generatedContent
        guard case .string(let s) = content.kind else {
            Issue.record("Expected string kind"); return
        }
        #expect(s == "test")
    }

    // MARK: - Bool

    @Test("Bool round-trip")
    func boolRoundTrip() throws {
        let trueContent = true.generatedContent
        #expect(try Bool(trueContent) == true)

        let falseContent = false.generatedContent
        #expect(try Bool(falseContent) == false)
    }

    @Test("Bool from string")
    func boolFromString() throws {
        #expect(try Bool(GeneratedContent(kind: .string("true"))) == true)
        #expect(try Bool(GeneratedContent(kind: .string("false"))) == false)
        #expect(try Bool(GeneratedContent(kind: .string("yes"))) == true)
        #expect(try Bool(GeneratedContent(kind: .string("no"))) == false)
    }

    @Test("Bool from invalid string throws")
    func boolFromInvalidString() {
        #expect(throws: DecodingError.self) {
            _ = try Bool(GeneratedContent(kind: .string("maybe")))
        }
    }

    // MARK: - Int

    @Test("Int round-trip")
    func intRoundTrip() throws {
        let original = 42
        let content = original.generatedContent
        let restored = try Int(content)
        #expect(restored == original)
    }

    @Test("Int from string")
    func intFromString() throws {
        let content = GeneratedContent(kind: .string("123"))
        #expect(try Int(content) == 123)
    }

    @Test("Int rejects decimal numbers")
    func intRejectsDecimal() {
        let content = GeneratedContent(kind: .number(3.14))
        #expect(throws: DecodingError.self) {
            _ = try Int(content)
        }
    }

    // MARK: - Double

    @Test("Double round-trip")
    func doubleRoundTrip() throws {
        let original = 3.14
        let content = original.generatedContent
        let restored = try Double(content)
        #expect(restored == original)
    }

    @Test("Double from string")
    func doubleFromString() throws {
        let content = GeneratedContent(kind: .string("2.718"))
        #expect(try Double(content) == 2.718)
    }

    // MARK: - Float

    @Test("Float round-trip")
    func floatRoundTrip() throws {
        let original: Float = 1.5
        let content = original.generatedContent
        let restored = try Float(content)
        #expect(restored == original)
    }

    // MARK: - Decimal

    @Test("Decimal round-trip")
    func decimalRoundTrip() throws {
        let original = Decimal(string: "99.99")!
        let content = original.generatedContent
        let restored = try Decimal(content)
        #expect(abs(NSDecimalNumber(decimal: restored - original).doubleValue) < 0.01)
    }

    @Test("Decimal from string")
    func decimalFromString() throws {
        let content = GeneratedContent(kind: .string("123.456"))
        let decimal = try Decimal(content)
        #expect(decimal == Decimal(string: "123.456"))
    }

    // MARK: - UUID

    @Test("UUID round-trip")
    func uuidRoundTrip() throws {
        let original = UUID()
        let content = original.generatedContent
        let restored = try UUID(content)
        #expect(restored == original)
    }

    @Test("UUID parsing various formats")
    func uuidParsing() throws {
        let lower = "550e8400-e29b-41d4-a716-446655440000"
        let uuid = try UUID(GeneratedContent(kind: .string(lower)))
        #expect(uuid.uuidString.lowercased() == lower)
    }

    @Test("UUID rejects invalid format")
    func uuidRejectsInvalid() {
        #expect(throws: DecodingError.self) {
            _ = try UUID(GeneratedContent(kind: .string("not-a-uuid")))
        }
    }

    // MARK: - Date

    @Test("Date round-trip within 1ms")
    func dateRoundTrip() throws {
        let original = Date()
        let content = original.generatedContent
        let restored = try Date(content)
        #expect(abs(restored.timeIntervalSince(original)) < 0.001)
    }

    @Test("Date parsing ISO 8601 formats")
    func dateParsing() throws {
        let withFractional = try Date(GeneratedContent(kind: .string("2024-01-15T10:30:45.123Z")))
        #expect(withFractional.timeIntervalSince1970 > 0)

        let withoutFractional = try Date(GeneratedContent(kind: .string("2024-01-15T10:30:45Z")))
        #expect(withoutFractional.timeIntervalSince1970 > 0)
    }

    @Test("Date parsing from Unix timestamp")
    func dateFromTimestamp() throws {
        let date = try Date(GeneratedContent(kind: .string("1705315845")))
        #expect(date.timeIntervalSince1970 == 1705315845)
    }

    @Test("Date rejects invalid string")
    func dateRejectsInvalid() {
        #expect(throws: DecodingError.self) {
            _ = try Date(GeneratedContent(kind: .string("not-a-date")))
        }
    }

    // MARK: - URL

    @Test("URL round-trip")
    func urlRoundTrip() throws {
        let original = URL(string: "https://example.com/path?q=1")!
        let content = original.generatedContent
        let restored = try URL(content)
        #expect(restored == original)
    }

    @Test("URL parsing various schemes")
    func urlParsing() throws {
        let http = try URL(GeneratedContent(kind: .string("http://example.com")))
        #expect(http.scheme == "http")

        let file = try URL(GeneratedContent(kind: .string("file:///tmp/test.txt")))
        #expect(file.scheme == "file")
    }

    @Test("URL rejects empty string")
    func urlRejectsEmpty() {
        #expect(throws: DecodingError.self) {
            _ = try URL(GeneratedContent(kind: .string("")))
        }
    }

    // MARK: - Never

    @Test("Never init throws")
    func neverInitThrows() {
        #expect(throws: DecodingError.self) {
            _ = try Never(GeneratedContent(""))
        }
    }

    // MARK: - GenerationSchema

    @Test("Standard types have generationSchema")
    func standardTypeSchemas() {
        #expect(String.generationSchema.description != nil)
        #expect(Bool.generationSchema.description != nil)
        #expect(Int.generationSchema.description != nil)
        #expect(Double.generationSchema.description != nil)
        #expect(Float.generationSchema.description != nil)
        #expect(UUID.generationSchema.description != nil)
        #expect(Date.generationSchema.description != nil)
        #expect(URL.generationSchema.description != nil)
    }
}
