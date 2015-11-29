//
//  NSString+URLEncoding.m
//


#import "NSMutableArray+AddUnique.h"

@implementation NSMutableArray (AddUniqueString)

- (BOOL) addUniqueString:(NSString *)string
{
    NSInteger index = [self findString:string caseSensitive:YES];
    if ( index >= 0 )
        return NO;
    
    [self addObject:string];
    return YES;
}

- (BOOL) addUniqueCaseString:(NSString *)string
{
    NSInteger index = [self findString:string caseSensitive:NO];
    if ( index >= 0 )
        return NO;
    
    [self addObject:string];
    return YES;
}

- (NSInteger) findString:(NSString *)string caseSensitive:(BOOL)caseSensitive
{
    for ( NSObject * obj in self )
    {
        if ( [obj isKindOfClass:[NSString class]] )
        {
            NSString * str = (NSString *)obj;
            if ( caseSensitive )
            {
                if ( [str isEqualToString:string] )
                {
                    return [self indexOfObject:obj];
                }
            }
            else
            {
                if ( [str caseInsensitiveCompare:string] == NSOrderedSame )
                {
                    return [self indexOfObject:obj];
                }
            }
        }
    }
    return -1;
}

@end
