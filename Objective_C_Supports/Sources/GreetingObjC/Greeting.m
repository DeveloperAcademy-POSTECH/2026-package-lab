#import "Greeting.h"
#import <Foundation/Foundation.h>

@implementation Greeting

- (void)sayHelloTo:(NSString *)name {
    NSLog(@"Hello, %@!", name);
}

- (void)sayHello {
    NSLog(@"Hello from Objective-C!");
}
- (void)sayGoodbye {
    NSLog(@"Goodbye from Objective-C!");
}

@end