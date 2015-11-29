//
//  WritePadPersistentData.h
//  WritePadEN
//
//  Created by Stanislav Miasnikov on 10/11/09.
//  Copyright 2009 PhatWare Corp.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIPasteboard.h>

enum 
{
	PRESISTDATA_USERDICT = 0x0001,
	PRESISTDATA_WORDLIST = 0x0002,
	PRESISTDATA_LEARNER  = 0x0004,
	PRESISTDATA_SHORTCUT = 0x0008,
	PRESISTDATA_SHAPES   = 0x0010
};

@class LanguageManager;

@interface WritePadPersistentData : NSObject 
{
}

- (id) initWithLanguageManager:(LanguageManager *)langMan;
- (NSUInteger) updatePersistentData:(BOOL)force;
- (NSUInteger) loadPersistentData:(Boolean)force;
- (NSUInteger) reloadPersistentDataIfNeeded;


@end
