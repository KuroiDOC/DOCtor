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
        
        Container.main.register(Factory { Foo() })
        Container.main.register(Factory { Bar(msg: "HI") })
        Container.main.register(Factory { Bar(msg: "BYE") }, name: "Bar2")

        let foo = Container.main.resolve(Foo.self)
        XCTAssertNotNil(foo)
        XCTAssertEqual(foo?.bar.msg,"HI")
        XCTAssertEqual(foo?.bar2.msg,"BYE")
        
        Container.main.register(Single { Singleton(msg: "Singleton") })
        let s1 = Container.main.resolve(Singleton.self)
        let s2 = Container.main.resolve(Singleton.self)
        XCTAssertTrue(s1 === s2)
        
        Container.main.register(Factory { Singleton(msg: "Singleton") }, name: "FakeSingleton")
        let s3 = Container.main.resolve(Singleton.self, name: "FakeSingleton")
        let s4 = Container.main.resolve(Singleton.self, name: "FakeSingleton")
        XCTAssertFalse(s3 === s4)
        
        Container.main.register(Single { Bar(msg: "Struct") }, name: "singleBar")
        var s5 = Container.main.resolve(Bar.self, name: "singleBar")
        var s6 = Container.main.resolve(Bar.self, name: "singleBar")
        compareMemAddress(p1: &s5, p2: &s6) { p1, p2 in
            XCTAssertNotEqual(p1, p2)
        }
    }
    
    func compareMemAddress<T>(p1: UnsafePointer<T>,p2: UnsafePointer<T>, closure: (UnsafePointer<T>,UnsafePointer<T>) -> Void) {
        closure(p1,p2)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
