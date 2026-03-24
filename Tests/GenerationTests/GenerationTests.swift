import Testing
import Generation
import GenerationMacros

@Suite
struct GenerationTests {
    @Test func generatedContentBasics() throws {
        let content = GeneratedContent(kind: .string("hello"))
        let value = try content.value(String.self)
        #expect(value == "hello")
    }
}
