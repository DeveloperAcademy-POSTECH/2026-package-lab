import GreetingObjC

public func runGreeting() {
    let greeting = Greeting()

    print(type(of: greeting))

    greeting.sayHello()
    greeting.sayGoodbye()
    greeting.greet(person: "Baek")
    
}