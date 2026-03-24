import Testing
import Foundation
@testable import Generation
import GenerationMacros

@Generable
struct SimpleValue {
    let value: String
}

@Generable
struct Person {
    let name: String
    let age: Int
}

@Generable(description: "User status")
enum Status {
    case active
    case inactive
    case pending
}

@Generable(description: "Task result")
enum TaskResult {
    case success(message: String)
    case failure(error: String, code: Int)
    case pending
}

@Generable
enum Color: Equatable {
    case red
    case green
    case blue
}

@Generable
struct WithGuide {
    @Guide(description: "User name")
    var name: String
}

@Generable
struct WithCustomInit {
    @Guide(description: "Label")
    var label: String

    init(label: String) {
        self.label = label
    }
}

@Suite("@Generable Macro")
struct GenerableMacroTests {

    @Test("Struct compiles and conforms to Generable")
    func structCompilation() throws {
        let content = try GeneratedContent(json: "{\"value\": \"test\"}")
        let instance = try SimpleValue(content)
        #expect(instance.value == "test")

        let schema = SimpleValue.generationSchema
        #expect(schema.debugDescription.contains("GenerationSchema"))
    }

    @Test("Struct generatedContent round-trip")
    func structRoundTrip() throws {
        let json = try GeneratedContent(json: "{\"name\": \"Alice\", \"age\": 30}")
        let person = try Person(json)
        #expect(person.name == "Alice")
        #expect(person.age == 30)

        let content = person.generatedContent
        let restored = try Person(content)
        #expect(restored.name == "Alice")
        #expect(restored.age == 30)
    }

    @Test("Simple enum from string")
    func simpleEnumFromString() throws {
        let active = try Status(GeneratedContent("active"))
        #expect(active == .active)

        let pending = try Status(GeneratedContent("pending"))
        #expect(pending == .pending)
    }

    @Test("Simple enum to generatedContent")
    func simpleEnumToContent() {
        let content = Status.active.generatedContent
        #expect(content.text == "active")
    }

    @Test("Simple enum invalid value throws")
    func simpleEnumInvalidThrows() {
        #expect(throws: Error.self) {
            _ = try Status(GeneratedContent("unknown"))
        }
    }

    @Test("Equatable enum from string")
    func equatableEnumFromString() throws {
        let red = try Color(GeneratedContent("red"))
        #expect(red == .red)

        let blue = try Color(GeneratedContent("blue"))
        #expect(blue == .blue)

        #expect(throws: Error.self) {
            _ = try Color(GeneratedContent("yellow"))
        }
    }

    @Test("Enum with associated values - pending")
    func enumAssocPending() throws {
        let pending = TaskResult.pending
        let content = pending.generatedContent
        let props = try content.properties()
        #expect(props["case"]?.text == "pending")
    }

    @Test("Enum with associated values - success")
    func enumAssocSuccess() throws {
        let result = TaskResult.success(message: "Done")
        let content = result.generatedContent
        let props = try content.properties()
        #expect(props["case"]?.text == "success")
        let valueProps = try props["value"]?.properties()
        #expect(valueProps?["message"]?.text == "Done")
    }

    @Test("Enum with associated values - failure")
    func enumAssocFailure() throws {
        let result = TaskResult.failure(error: "Timeout", code: 408)
        let content = result.generatedContent
        let props = try content.properties()
        #expect(props["case"]?.text == "failure")
        let valueProps = try props["value"]?.properties()
        #expect(valueProps?["error"]?.text == "Timeout")
        #expect(valueProps?["code"]?.text == "408")
    }

    @Test("Enum init from JSON - associated values")
    func enumInitFromJson() throws {
        let successJson = try GeneratedContent(json: """
        {"case": "success", "value": {"message": "OK"}}
        """)
        let success = try TaskResult(successJson)
        if case .success(let msg) = success {
            #expect(msg == "OK")
        } else {
            Issue.record("Expected success case")
        }

        let failureJson = try GeneratedContent(json: """
        {"case": "failure", "value": {"error": "Bad", "code": "500"}}
        """)
        let failure = try TaskResult(failureJson)
        if case .failure(let err, let code) = failure {
            #expect(err == "Bad")
            #expect(code == 500)
        } else {
            Issue.record("Expected failure case")
        }
    }

    @Test("Struct with @Guide")
    func structWithGuide() throws {
        let json = try GeneratedContent(json: "{\"name\": \"Bob\"}")
        let instance = try WithGuide(json)
        #expect(instance.name == "Bob")
    }

    @Test("Struct with custom init preserves both inits")
    func structWithCustomInit() throws {
        let fromInit = WithCustomInit(label: "A")
        #expect(fromInit.label == "A")

        let fromContent = try WithCustomInit(GeneratedContent(json: "{\"label\": \"B\"}"))
        #expect(fromContent.label == "B")

        let roundTrip = try WithCustomInit(fromInit.generatedContent)
        #expect(roundTrip.label == "A")
    }

    @Test("PartiallyGenerated from complete content has all fields")
    func partiallyGeneratedComplete() throws {
        let json = try GeneratedContent(json: "{\"name\": \"Alice\", \"age\": 30}")
        let person = try Person(json)
        let partial = person.asPartiallyGenerated()
        #expect(partial.name == "Alice")
        #expect(partial.age == 30)
    }

    @Test("PartiallyGenerated from partial content has nil for missing fields")
    func partiallyGeneratedPartial() throws {
        let json = try GeneratedContent(json: "{\"name\": \"Bob\"}")
        let person = try Person(json)
        let partial = person.asPartiallyGenerated()
        #expect(partial.name == "Bob")
        #expect(partial.age == nil)
    }

    @Test("PartiallyGenerated from empty content has all nil")
    func partiallyGeneratedEmpty() throws {
        let json = try GeneratedContent(json: "{}")
        let person = try Person(json)
        let partial = person.asPartiallyGenerated()
        #expect(partial.name == nil)
        #expect(partial.age == nil)
    }

    @Test("PartiallyGenerated init directly from GeneratedContent")
    func partiallyGeneratedDirect() throws {
        let json = try GeneratedContent(json: "{\"name\": \"Carol\"}")
        let partial = try Person.PartiallyGenerated(json)
        #expect(partial.name == "Carol")
        #expect(partial.age == nil)
    }

    @Test("generationSchema exists for all macro types")
    func schemasExist() {
        _ = SimpleValue.generationSchema
        _ = Person.generationSchema
        _ = Status.generationSchema
        _ = TaskResult.generationSchema
        _ = Color.generationSchema
        _ = WithGuide.generationSchema
        _ = WithCustomInit.generationSchema
        #expect(Bool(true))
    }
}
