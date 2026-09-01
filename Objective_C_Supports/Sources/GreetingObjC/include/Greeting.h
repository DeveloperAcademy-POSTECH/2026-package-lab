#import <Foundation/Foundation.h>

@interface Greeting : NSObject

- (void)sayHelloTo:(NSString *)name
    NS_SWIFT_NAME(greet(person:));
- (void)sayHello;
- (void)sayGoodbye;

@end