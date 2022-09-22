import XCTest
@testable import DOCtor

final class DOCtorTests: XCTestCase {
    
    struct Foo {
        @Injectable var bar: Bar
        @Injectable(name: "Bar2") var bar2: Bar
    }

    struct Bar {
        var msg: String
    }
    
    struct Baz { }
    
    class Singleton {
        var msg: String

        init(msg: String) {
            self.msg = msg
        }
    }
    
    func testExample() {
        Container.main.register(Factory { Foo() })
        Container.main.register(Factory { Bar(msg: "HI") })
        Container.main.register(Factory(name: "Bar2") { Bar(msg: "BYE") })

        let foo = Container.main.resolve(Foo.self)
        XCTAssertNotNil(foo)
        XCTAssertEqual(foo?.bar.msg,"HI")
        XCTAssertEqual(foo?.bar2.msg,"BYE")
        
        Container.main.register(Single { Singleton(msg: "Singleton") })
        let s1 = Container.main.resolve(Singleton.self)
        let s2 = Container.main.resolve(Singleton.self)
        XCTAssertTrue(s1 === s2)
        
        Container.main.register(Factory(name: "FakeSingleton") { Singleton(msg: "Singleton") })
        let s3 = Container.main.resolve(name: "FakeSingleton", Singleton.self)
        let s4 = Container.main.resolve(name: "FakeSingleton", Singleton.self)
        XCTAssertFalse(s3 === s4)
        
        Container.main.register(Single(name: "singleBar") { Bar(msg: "Struct") })
        var s5 = Container.main.resolve(name: "singleBar", Bar.self)
        var s6 = Container.main.resolve(name: "singleBar", Bar.self)
        compareMemAddress(p1: &s5, p2: &s6) { p1, p2 in
            XCTAssertNotEqual(p1, p2)
        }
        
        Container.main.register(Factory(name: "Clash") { Bar(msg: "Clash") })
        Container.main.register(Factory(name: "Clash") { Baz() })
        let s7 = Container.main.resolve(name: "Clash", Bar.self)
        let s8 = Container.main.resolve(name: "Clash", Baz.self)
        XCTAssertNotNil(s7)
        XCTAssertEqual(s7?.msg, "Clash")
        XCTAssertNotNil(s8)
        
        Container.main.reset()
        XCTAssertNil(Container.main.resolve(Foo.self))
    }
    
    func testResultBuilder() {
        Container.main.register {
            Factory { Foo() }
            Factory { Bar(msg: "HI") }
            Factory(name: "Bar2") { Bar(msg: "BYE") }
            Single(name: "singleBar") { Bar(msg: "Struct") }
        }
        
        let foo = Container.main.resolve(Foo.self)
        XCTAssertNotNil(foo)
        XCTAssertEqual(foo?.bar.msg,"HI")
        XCTAssertEqual(foo?.bar2.msg,"BYE")
        
        var s1 = Container.main.resolve(name: "singleBar", Bar.self)
        var s2 = Container.main.resolve(name: "singleBar", Bar.self)
        compareMemAddress(p1: &s1, p2: &s2) { p1, p2 in
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
