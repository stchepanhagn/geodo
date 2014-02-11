//
//  TDGlobalConfiguration.m
//  ProjectToDos
//
//  Created by Stephan Chang on 2/11/14.
//  Copyright (c) 2014 The ToDo Party. All rights reserved.
//

#import "TDGlobalConfiguration.h"

@implementation TDGlobalConfiguration

+ (UIColor *)fontColor
{
    return [UIColor colorWithRed:231.0f/255.0f green:238.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (UIColor *)backgroundColor
{
    return [UIColor colorWithRed:72.0f/255.0f green:154.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
}

+ (UIColor *)controlBackgroundColor
{
    return [UIColor colorWithRed:22.0f/255.0f green:48.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
}

+ (UIColor *)cellBackgroundColor
{
    return [UIColor colorWithRed:72.0f/255.0f green:154.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
}

+ (NSString *)fontName
{
    return @"Palatino";
}

+ (float)fontSize
{
    return 17.0f;
}

+ (short)characterLimit
{
    return 40;
}

@end
