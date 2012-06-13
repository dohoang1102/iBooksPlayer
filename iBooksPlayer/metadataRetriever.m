//
//  metadataRetriever.m
//  metadataRetriever
//
//  Created by Nathaniel Symer on 12/20/11.
//  Do whatever you want with this, just don't pass it 
//  off as your own or sell it.
//

#import "metadataRetriever.h"
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation metadataRetriever

+ (NSArray *)getMetadataForFile:(NSString *)filePath {
    
    NSURL *fileURL = [[NSURL alloc]initFileURLWithPath:filePath];
    
    AudioFileID fileID = nil;
    OSStatus err = noErr;
    
    err = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, 0, &fileID);
    if (err != noErr) {
        NSLog(@"AudioFileOpenURL failed");
        return [[NSArray alloc]initWithObjects:@"---", @"---", @"---", nil];
    }
    
    UInt32 id3DataSize = 0;
    char *rawID3Tag = NULL;
    
    err = AudioFileGetPropertyInfo(fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL);
    if (err != noErr) {
        NSLog(@"AudioFileGetPropertyInfo failed");
        return [[NSArray alloc] initWithObjects:@"---", @"---", @"---", nil];
    }
    
    rawID3Tag = (char *)malloc(id3DataSize);
    if (rawID3Tag == NULL) {
        NSLog(@"Couldn't allocate %lu bytes of memory for the ID3 tag", id3DataSize);
        return [[NSArray alloc] initWithObjects:@"---", @"---", @"---", nil];
    }
    
    err = AudioFileGetProperty(fileID, kAudioFilePropertyID3Tag, &id3DataSize, rawID3Tag);
    if (err != noErr) {
        NSLog(@"AudioFileGetProperty failed for ID3 tag");
        return [[NSArray alloc] initWithObjects:@"---", @"---", @"---", nil];
    }
    
    int ilim = 100;
    if (ilim > id3DataSize) {
        ilim = id3DataSize;
    }
    
    // prints the raw ID3 tag to the debugger, for debugging puposes
    /*for (int i=0; i < ilim; i++) {
        if( rawID3Tag[i] < 32 ) {
            printf( "." );
        } else {
            printf( "%c", rawID3Tag[i] );
        }
    }*/
    
    UInt32 id3TagSize = 0;
    UInt32 id3TagSizeLength = 0;
    err = AudioFormatGetProperty(kAudioFormatProperty_ID3TagSize, id3DataSize, rawID3Tag, &id3TagSizeLength, &id3TagSize);
    
    
    if(err != noErr) {
        NSLog(@"AudioFormatGetProperty failed for ID3 tag size");
        switch(err) {
            case kAudioFormatUnspecifiedError:
                NSLog(@"err: audio format unspecified error" ); 
                break;
            case kAudioFormatUnsupportedPropertyError:
                NSLog(@"err: audio format unsupported property error" ); 
                break;
            case kAudioFormatBadPropertySizeError:
                NSLog(@"err: audio format bad property size error" ); 
                break;
            case kAudioFormatBadSpecifierSizeError:
                NSLog(@"err: audio format bad specifier size error" ); 
                break;
            case kAudioFormatUnsupportedDataFormatError:
                NSLog(@"err: audio format unsupported data format error"); 
                break;
            case kAudioFormatUnknownFormatError:
                NSLog(@"err: audio format unknown format error"); 
                break;
            default:
                NSLog(@"err: some other audio format error"); 
                break;
        }
        return [[NSArray alloc] initWithObjects:@"---", @"---", @"---", nil];
    }
    
    CFDictionaryRef piDict = nil;
    UInt32 piDataSize = sizeof(piDict);
    
    err = AudioFileGetProperty(fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
    if(err != noErr) {
        NSLog(@"AudioFileGetProperty failed for the property: InfoDictionary");
        return [[NSArray alloc] initWithObjects:@"---", @"---", @"---", @"---", nil];
    }
    
    
    NSString *artistCF = (__bridge NSString *)CFDictionaryGetValue(piDict, CFSTR(kAFInfoDictionary_Artist));
    NSString *songCF = (__bridge NSString *)CFDictionaryGetValue(piDict, CFSTR(kAFInfoDictionary_Title));
    NSString *albumCF = (__bridge NSString *)CFDictionaryGetValue(piDict, CFSTR(kAFInfoDictionary_Album));
    NSString *commentsCF = (__bridge NSString *)CFDictionaryGetValue(piDict, CFSTR(kAFInfoDictionary_Comments));
    
    NSString *artist = [NSString stringWithFormat:@"%@",artistCF];
    NSString *song = [NSString stringWithFormat:@"%@",songCF];
    NSString *album = [NSString stringWithFormat:@"%@",albumCF];
    NSString *comments = [NSString stringWithFormat:@"%@",commentsCF];
    
    NSString *artistNil = [NSString stringWithString:@"---"];
    NSString *songNil = [NSString stringWithString:@"---"];
    NSString *albumNil = [NSString stringWithString:@"---"];
    NSString *commentsNil = [NSString stringWithString:@"---"];
    
    BOOL artistIsNil = [artist isEqualToString:@"(null)"];
    BOOL albumIsNil = [album isEqualToString:@"(null)"];
    BOOL songIsNil = [song isEqualToString:@"(null)"];
    BOOL commentsIsNil = [song isEqualToString:@"(null)"];
    
    NSMutableArray *initArray = [[NSMutableArray alloc]initWithCapacity:10];
    if (artistIsNil) {
        [initArray addObject:artistNil];
    } else {
        [initArray addObject:artist];
    }
    if (songIsNil) {
        [initArray addObject:songNil];
    } else {
        [initArray addObject:song];
    } 
    
    if (albumIsNil) {
        [initArray addObject:albumNil];
    } else {
        [initArray addObject:album];
    }
   
   if (commentsIsNil) {
      [initArray addObject:commentsNil];
   } else {
      [initArray addObject:comments];
   }
    
    CFRelease(piDict);
    free(rawID3Tag);
    
    NSArray *theArray = [[NSArray alloc]initWithArray:initArray];
    
    return theArray;
}

@end
