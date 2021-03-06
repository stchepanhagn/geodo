//
//  TDAppDelegate.h
//  ProjectToDos
//
//  Created by Stephan Chang on 1/27/14.
//  Copyright (c) 2014 The ToDo Party. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKitDragAndDropViewController.h"

@interface TDAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow *window;
    MapKitDragAndDropViewController *viewController;
}
@property (strong, nonatomic) UIWindow *window;
@end
