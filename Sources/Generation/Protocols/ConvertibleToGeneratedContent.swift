import Foundation

public protocol ConvertibleToGeneratedContent: InstructionsRepresentable, PromptRepresentable {
    var generatedContent: GeneratedContent { get }
}

extension ConvertibleToGeneratedContent {
    public var instructionsRepresentation: Instructions {
        return Instructions(generatedContent.jsonString)
    }

    public var promptRepresentation: Prompt {
        return Prompt(generatedContent.jsonString)
    }
}
