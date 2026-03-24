import Foundation

extension Bool: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: Bool.self,
            description: "A boolean value",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        switch content.kind {
        case .bool(let value):
            self = value
        case .number(let value):
            self = value != 0
        case .string(let s):
            let text = s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            switch text {
            case "true", "yes", "1":
                self = true
            case "false", "no", "0":
                self = false
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Unable to decode Bool from string: \(s)"
                    )
                )
            }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to decode Bool from Kind: \(content.kind)"
                )
            )
        }
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .bool(self))
    }
}
