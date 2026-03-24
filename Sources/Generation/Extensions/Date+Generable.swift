import Foundation

extension Date: Generable {
    private static func createISO8601Formatter(withFractionalSeconds: Bool = true) -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = withFractionalSeconds
            ? [.withInternetDateTime, .withFractionalSeconds]
            : [.withInternetDateTime]
        return formatter
    }

    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: Date.self,
            description: "A date and time value in ISO 8601 format (e.g., '2024-01-15T10:30:00.000Z')",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        let text = content.text.trimmingCharacters(in: .whitespacesAndNewlines)

        let formatterWithFractional = Self.createISO8601Formatter(withFractionalSeconds: true)
        if let date = formatterWithFractional.date(from: text) {
            self = date
        } else {
            let formatterNoFractional = Self.createISO8601Formatter(withFractionalSeconds: false)
            if let date = formatterNoFractional.date(from: text) {
                self = date
            } else {
                if let timestamp = Double(text) {
                    self = Date(timeIntervalSince1970: timestamp)
                } else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: [],
                            debugDescription: "Unable to decode Date from: '\(text)'. Expected ISO 8601 format or Unix timestamp."
                        )
                    )
                }
            }
        }
    }

    public var generatedContent: GeneratedContent {
        let formatter = Self.createISO8601Formatter(withFractionalSeconds: true)
        return GeneratedContent(kind: .string(formatter.string(from: self)))
    }
}
