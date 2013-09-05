//
//  PSAnalyzer.h
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSAnalysis.h" 

@interface PSAnalyzer : NSObject

- (PSAnalyzer *) initWithATTData: (NSData *)attData;
- (PSAnalyzer *) initWithATTDataAtURL: (NSURL *)attDataURL;

- (PSAnalysis *) analyze: (NSString *)form;


@end
