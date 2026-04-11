import Foundation

extension Decimal: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: Decimal.self,
            description: "A decimal number with arbitrary precision",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        switch content.kind {
        case .number(let value):
            self = Decimal(value)
        case .string(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value = Decimal(string: trimmed) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Unable to decode Decimal from: \(text)"
                    )
                )
            }
            self = value
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to decode Decimal from Kind: \(content.kind)"
                )
            )
        }
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .number(NSDecimalNumber(decimal: self).doubleValue))
    }
}
