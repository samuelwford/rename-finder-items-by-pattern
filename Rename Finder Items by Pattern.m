//
//  Rename Finder Items by Pattern.m
//  Rename Finder Items by Pattern
//
//  Created by Samuel Ford on 8/29/09.
//  Copyright (c) 2009 __MyCompanyName__, All Rights Reserved.
//

#import "Rename Finder Items by Pattern.h"
#import <OSAKit/OSAKit.h>


@implementation Rename_Finder_Items_by_Pattern

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
	// 1. iterate over the set
	// 2. apply a glob-like pattern (e.g. *x*y*z*) where each glob is a numbered section
	// 3. rename with replaces (e.g. abc-$2-xyz-$1)
	// example:
	// filename: img_0001.jpg
	// pattern: *_*
	// replacement: image-$2
	// output: image-0001.jpg
	
	// would be cool to somehow use the colored token things so the user can visualize the result
	// may add formatting options (so the parsed bits can be interpretted as numbers, dates, etc)

	NSMutableArray *output = [[NSMutableArray alloc] init];
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSArray *globs = [[[self parameters] objectForKey:@"searchFor"] componentsSeparatedByString:@"*"];

	NSString *path;
	NSString *fileWithExt;
	NSString *ext;
	NSString *fileWithoutExt;
	
	NSScanner *scanner;
	NSMutableArray *parsedSections;
	NSString *interstitial;
	NSString *part;
	NSString *chunk;
	
	BOOL success;
	BOOL found;
	
	NSMutableString *result;
	NSScanner *patternScanner;
	NSCharacterSet *tokenSet = [NSCharacterSet characterSetWithCharactersInString:@"$"];
	NSCharacterSet *emptySet = [NSCharacterSet characterSetWithCharactersInString:@""];
	NSInteger token;
	NSString *newPath;
	NSError *error = nil;
	
	for (NSString *file in input)
	{
		// try to get the base name of the file minus extension
		path = [file stringByDeletingLastPathComponent];
		fileWithExt = [file lastPathComponent];
		ext = [fileWithExt pathExtension];
		fileWithoutExt = [fileWithExt stringByDeletingPathExtension];
				
		scanner = [NSScanner scannerWithString:fileWithoutExt];
		[scanner setCharactersToBeSkipped:emptySet];
		
		parsedSections = [[NSMutableArray alloc] initWithCapacity:[globs count]];
		
		// now, use the globs to parse out bits of the file
		for (int i = 0; i < [globs count]; i++)
		{
			// scan forward to find the next occurance of the pattern, grabbing everything up to it
			// unless it's empty
			
			interstitial = [globs objectAtIndex:i];
			
			if (i == 0 && [interstitial length] == 0) continue;
			
			part = @"";
			
			success = [scanner scanUpToString:interstitial intoString:&part];			
			success = [scanner scanString:interstitial intoString:NULL];
			
			if ([part length] > 0) [parsedSections addObject:part];
						
			if (!success) break;
		}
		
		// now, construct the result
		// use a scanner to look for $x and insert the number
		
		result = [NSMutableString stringWithCapacity:100];
		patternScanner = [NSScanner scannerWithString:[[self parameters] objectForKey:@"replaceWith"]];
		[patternScanner setCharactersToBeSkipped:emptySet];
		
		while ([patternScanner isAtEnd] == NO) {
			chunk = @"";
			found = [patternScanner scanUpToCharactersFromSet:tokenSet intoString:&chunk];
			[result appendString:chunk];
			
			if ([patternScanner isAtEnd]) {
				break;
			}
			
			[patternScanner scanCharactersFromSet:tokenSet intoString:NULL];
			found = [patternScanner scanInteger:&token];
			
			if (found) {
				if (token > 0 && token < [parsedSections count] + 1) {
					[result appendString:[parsedSections objectAtIndex:token - 1]];
				}
			}
			else {
				[result appendString:@"$"];
			}
		}
		
		newPath = [path stringByAppendingPathComponent:[result stringByAppendingPathExtension:ext]];
		
		if (![fm moveItemAtPath:file toPath:newPath error:&error]) {
			NSLog(@"rename by pattern: unable to rename '%@' to '%@' [%@]",  file, newPath, error);
			NSArray *oa = [NSArray arrayWithObjects:
						   [NSNumber numberWithInt:errOSAGeneralError],
						   [NSString stringWithFormat:@"Could not rename to %@", newPath],
						   nil];
			NSArray *ka = [NSArray arrayWithObjects:
						   OSAScriptErrorNumber, OSAScriptErrorMessage, nil];
			
			*errorInfo = [NSDictionary dictionaryWithObjects:oa forKeys:ka];
		} else {
			[output addObject:newPath];
			NSLog(@"rename by pattern: renamed '%@' to '%@'", file, newPath);
		}		
	}
	
	return output;
}

@end
