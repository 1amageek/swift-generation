import Foundation

extension String: InstructionsRepresentable {
    public var instructionsRepresentation: Instructions {
        return Instructions(self)
    }
}

extension String: PromptRepresentable {
    public var promptRepresentation: Prompt {
        return Prompt(self)
    }
}
