//
//  Rename Finder Items by Pattern.h
//  Rename Finder Items by Pattern
//
//  Created by Samuel Ford on 8/29/09.
//  Copyright (c) 2009 __MyCompanyName__, All Rights Reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>


@interface Rename_Finder_Items_by_Pattern : AMBundleAction 
{
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
