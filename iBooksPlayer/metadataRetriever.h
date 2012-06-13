//
//  metadataRetriever.h
//  SwiftLoad
//
//  Created by Nathaniel Symer on 12/20/11.
//  Do whatever you want with this, just don't pass it 
//  off as your own or sell it.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface metadataRetriever : NSObject

+ (NSArray *)getMetadataForFile:(NSString *)filePath;

@end
