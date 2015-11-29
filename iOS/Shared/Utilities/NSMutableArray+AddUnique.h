//
//  NSMutableArray+AddUnique.h
//


#import <Foundation/Foundation.h>


@interface NSMutableArray (AddUniqueString)

- (BOOL) addUniqueString:(NSString *)string;
- (BOOL) addUniqueCaseString:(NSString *)string;
- (NSInteger) findString:(NSString *)string caseSensitive:(BOOL)caseSensitive;

@end
