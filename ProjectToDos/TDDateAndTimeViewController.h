//
//  TDDateAndTimeViewController.h
//  ProjectToDos
//
//  Created by Eduardo Thiesen on 2/2/14.
//  Copyright (c) 2014 The ToDo Party. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDToDo.h"
#import "TDEditToDoViewController.h"

@interface TDDateAndTimeViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *lblSabado;
@property (weak, nonatomic) IBOutlet UILabel *lblSexta;
@property (weak, nonatomic) IBOutlet UILabel *lblQuinta;
@property (weak, nonatomic) IBOutlet UILabel *lblQuarta;
@property (weak, nonatomic) IBOutlet UILabel *lblTerca;
@property (weak, nonatomic) IBOutlet UILabel *lblSegunda;
@property (weak, nonatomic) IBOutlet UILabel *lblDomingo;
@property (weak, nonatomic) IBOutlet UITableViewCell *cllHorario;
@property (strong, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *hourPickerCell;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIDatePicker *hourPicker;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *dateDetails;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UILabel *recurrent;
@property (weak, nonatomic) IBOutlet UILabel *hour;
@property (weak, nonatomic) IBOutlet UILabel *hourDetail;
@property (weak, nonatomic) IBOutlet UILabel *occurrence;
@property (weak, nonatomic) IBOutlet UILabel *occurrenceDetails;

@property (strong, nonatomic) TDToDo *todo;
@property (nonatomic, retain) TDEditToDoViewController *superController;

@end
