import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(ViewEquatableMacrosMacros)
import ViewEquatableMacrosMacros

private let testMacros: [String: Macro.Type] = [
    "Equatable": EquatableMacro.self,
    "SkipEquatable": SkipEquatableMacro.self,
]
#endif

final class ViewEquatableMacrosTests: XCTestCase {
    func testMultipleBindingsAreCompared() throws {
        #if canImport(ViewEquatableMacrosMacros)
        assertMacroExpansion(
            """
            @Equatable
            struct Example {
                var a = 1, b = 2
            }
            """,
            expandedSource: """
            struct Example {
                var a = 1, b = 2
            }

            extension Example: Swift.Equatable {
                static func == (
                    lhs: Self,
                    rhs: Self
                ) -> Bool {
                    lhs.a == rhs.a &&
                    lhs.b == rhs.b
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip(
            "Macro tests require the host platform"
        )
        #endif
    }
    
    func testObservedStoredPropertyIsCompared() throws {
        #if canImport(ViewEquatableMacrosMacros)
        assertMacroExpansion(
            """
            @Equatable
            struct Example {
                var count = 0 {
                    didSet {}
                }
            }
            """,
            expandedSource: """
                struct Example {
                    var count = 0 {
                        didSet {}
                    }
                }
                
                extension Example: Swift.Equatable {
                    static func == (
                        lhs: Self,
                        rhs: Self
                    ) -> Bool {
                        lhs.count == rhs.count
                    }
                }
                """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macro tests require the host platform")
        #endif
    }
    
    func testStaticAndComputedPropertiesAreExcluded() throws {
        #if canImport(ViewEquatableMacrosMacros)
        assertMacroExpansion(
            """
            @Equatable
            struct Example {
                static let defaultCount = 0
                let count: Int
            
                var doubledCount: Int {
                    count * 2
                }
            }
            """,
            expandedSource:
            """
            struct Example {
                static let defaultCount = 0
                let count: Int
            
                var doubledCount: Int {
                    count * 2
                }
            }
            
            extension Example: Swift.Equatable {
                static func == (
                    lhs: Self,
                    rhs: Self
                ) -> Bool {
                    lhs.count == rhs.count
                }
            }
            """,
            macros: testMacros
           )
        #else
        throw XCTSkip("Macro tests require the host platform")
        #endif
    }
}
