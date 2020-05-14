import XCTest
@testable import DOCtor

final class DOCtorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.


        struct Foo {
            @Injectable var bar: Bar
            @Injectable(name: "Bar2") var bar2: Bar
        }

        struct Bar {
            var msg: String
        }
        
        class Singleton {
            var msg: String

            init(msg: String) {
                self.msg = msg
            }
        }
        
        ApplicationContext.main.register(Foo.self) { Foo() }
        ApplicationContext.main.register(Bar.self) { Bar(msg: "HI") }
        ApplicationContext.main.register(Bar.self, name: "Bar2") { Bar(msg: "BYE") }

        let foo = ApplicationContext.main.resolve(Foo.self)
        XCTAssertNotNil(foo)
        XCTAssertEqual(foo?.bar.msg,"HI")
        XCTAssertEqual(foo?.bar2.msg,"BYE")
        
        ApplicationContext.main.registerSingleton(Singleton.self) { Singleton(msg: "Singleton") }
        let s1 = ApplicationContext.main.resolve(Singleton.self)
        let s2 = ApplicationContext.main.resolve(Singleton.self)
        XCTAssertTrue(s1 === s2)
        
        ApplicationContext.main.register(Singleton.self, name: "FakeSingleton") { Singleton(msg: "Singleton") }
        let s3 = ApplicationContext.main.resolve(Singleton.self, name: "FakeSingleton")
        let s4 = ApplicationContext.main.resolve(Singleton.self, name: "FakeSingleton")
        XCTAssertTrue(s3 !== s4)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
