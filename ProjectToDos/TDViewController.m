//
//  TDViewController.m
//  ProjectToDos
//
//  Created by Stephan Chang on 1/27/14.
//  Copyright (c) 2014 The ToDo Party. All rights reserved.
//

#import "TDViewController.h"
#import "TDEditToDoViewController.h"
#import "TDToDo.h"
#import "TDGlobalConfiguration.h"
#import "TDToDoCell.h"

@interface TDViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchAndAddTextField;
@property (weak, nonatomic) IBOutlet UITableView *toDosTableView;
@property (strong, nonatomic) NSMutableArray *toDosDataSource;
@property (strong, nonatomic) NSMutableArray *filteredToDosDataSource;
@property (nonatomic) BOOL isFiltering;

@end

@implementation TDViewController

#pragma mark Properties
- (NSMutableArray *)toDosDataSource {
    if (_toDosDataSource == nil)
        _toDosDataSource = [[NSMutableArray alloc] init];
    return _toDosDataSource;
}

- (NSMutableArray *)filteredToDosDataSource {
    if (_filteredToDosDataSource == nil)
        _filteredToDosDataSource = [[NSMutableArray alloc] init];
    return _filteredToDosDataSource;
}

#pragma mark Custom methods

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (NSAttributedString *)strikeThroughText:(NSString *)text
{
    NSDictionary* attributes = @{
                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                 };
    
    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attrText;
}

#pragma mark Actions
- (IBAction)onTheFlySearch:(UITextField *)sender {
    
    if (sender.text.length >= [TDGlobalConfiguration characterLimit]) {
        sender.text = [sender.text substringToIndex:[TDGlobalConfiguration characterLimit]];
    }
    
    self.isFiltering = YES;
    [self.filteredToDosDataSource removeAllObjects];
    [self.toDosTableView reloadData];
    
    if ([sender.text isEqualToString:@":Completas"]) {
     
        for (TDToDo *todo in self.toDosDataSource) {
            if (!todo.active) {

                [self.filteredToDosDataSource addObject:todo];
                [self.toDosTableView reloadData];
            }
        }
    } else {
    
        for (TDToDo *todo in self.toDosDataSource) {
            if (sender.text.length <= todo.description.length) {

                NSString *initials = [todo.description substringToIndex:sender.text.length];
                if ([initials isEqualToString:sender.text]) {
                    [self.filteredToDosDataSource addObject:todo];
                    [self.toDosTableView reloadData];
                }
            }
        }
    }
}

- (IBAction)addNewToDo:(UITextField *)sender {
    
    self.isFiltering = NO;
    if ([sender.text isEqualToString:@""] || [sender.text isEqualToString:@":Completas"]) {
        return;
    }
    
    [self.toDosTableView reloadData];
    [self.toDosTableView beginUpdates];
    {
        TDToDo *newTodo = [[TDToDo alloc] initWithDescription:sender.text];
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
        
        [self.toDosDataSource insertObject:newTodo atIndex:path.row];
        [self.toDosTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.toDosTableView endUpdates];

    [sender setText:@""];
}

#pragma mark Gestures

TDToDo *_selectedToDo;
NSIndexPath *_previousIndexPath;
- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (!self.isFiltering) {
        CGPoint touchLocation = [gestureRecognizer locationInView:self.toDosTableView];
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            
            [self hideKeyboard];
            
            _previousIndexPath = [self.toDosTableView indexPathForRowAtPoint:touchLocation];
            if (_previousIndexPath) {
                _selectedToDo = [self.toDosDataSource objectAtIndex:_previousIndexPath.row];
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            
            NSIndexPath *indexPathAtTouchLocation =  [self.toDosTableView indexPathForRowAtPoint:touchLocation];
            
            if (indexPathAtTouchLocation) {
                
                if (indexPathAtTouchLocation && indexPathAtTouchLocation.row != _previousIndexPath.row) {
                    
                    [self.toDosTableView beginUpdates];
                    {
                        [self.toDosTableView deleteRowsAtIndexPaths:@[_previousIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                        
                        // Depending on the relative position of the cell, its re-insertion in the table must consider its new position after its removal.
                        if (indexPathAtTouchLocation.row > _previousIndexPath.row) {
                            
                            [self.toDosDataSource insertObject:_selectedToDo atIndex:indexPathAtTouchLocation.row+1];
                            [self.toDosDataSource removeObjectAtIndex:_previousIndexPath.row];
                        } else {
                            
                            [self.toDosDataSource removeObjectAtIndex:_previousIndexPath.row];
                            [self.toDosDataSource insertObject:_selectedToDo atIndex:indexPathAtTouchLocation.row];
                        }
                        
                        [self.toDosTableView insertRowsAtIndexPaths:@[indexPathAtTouchLocation] withRowAnimation:UITableViewRowAnimationLeft];
                    };
                    [self.toDosTableView endUpdates];
                    _previousIndexPath =  [self.toDosTableView indexPathForRowAtPoint:touchLocation];
                }
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self.toDosTableView reloadData];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [gestureRecognizer translationInView:[self.toDosTableView superview]];
        // Handle horizontal pan only
        return fabsf(translation.x) > fabsf(translation.y);
    }
    
    return NO;
}

CGPoint _originalCenter, _cellLocation;
BOOL _markComplete, _detailToDo;
UITableViewCell *_firstCell;
- (void)panLeft:(UIPanGestureRecognizer *)recognizer {
    // When the pan begins, take note of what cell the gesture started at and its location.
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        _cellLocation = [recognizer locationInView:self.toDosTableView];
        NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:_cellLocation];
        _firstCell = [self.toDosTableView cellForRowAtIndexPath:indexPath];
        _originalCenter = _firstCell.center;
    }
    
    // Translates the cell, following the user's gesture.
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:_firstCell];
        _firstCell.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
        
        // Checks whether the cell has been moved to the far left or the far right
        // and flags an action as a consequence.
        _detailToDo = _firstCell.frame.origin.x < -_firstCell.frame.size.width / 3; // Panning to the left brings up the detailed ToDo View.
        _markComplete = _firstCell.frame.origin.x > _firstCell.frame.size.width/ 3; // Panning to the right marks the task as complete.
    }
    
    // When the user let go of the touch screen, decides whether an action needs to be taken and performs it.
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGRect originalFrame = CGRectMake(0, _firstCell.frame.origin.y,
                                          _firstCell.bounds.size.width, _firstCell.bounds.size.height);
        
        if (!_detailToDo && !_markComplete) {
            // if the item is not being deleted, snap back to the original location
            [UIView animateWithDuration:0.2
                             animations:^{
                                 _firstCell.frame = originalFrame;
                             }
             ];
        } else if (_detailToDo) {
            
            NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:_cellLocation];
            
            if (indexPath) {
                [self performSegueWithIdentifier:@"DetailToDo" sender:recognizer];
            }
        } else if (_markComplete) {
            
            NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:_cellLocation];
            TDToDo *toDo = [self.toDosDataSource objectAtIndex:indexPath.row];
            [toDo toggleActive];
            
            if (toDo.active) {
                
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];//[self getFirstNonPriorityIndex];
                
                [UIView animateWithDuration:.6 animations:^{
                    [self.toDosTableView beginUpdates];
                    
                    [self.toDosDataSource removeObjectAtIndex:indexPath.row];
                    [self.toDosDataSource insertObject:toDo atIndex:newIndexPath.row];
                    
                    [self.toDosTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                    [self.toDosTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
                    [self.toDosTableView endUpdates];
                }];
            } else {
                
                [UIView animateWithDuration:.6 animations:^{
                    
                    [self.toDosTableView beginUpdates];
                    
                    int newIndex = self.toDosDataSource.count-1;
                    
                    [self.toDosDataSource removeObjectAtIndex:indexPath.row];
                    [self.toDosDataSource insertObject:toDo atIndex:newIndex];
                    
                    [self.toDosTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                    [self.toDosTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newIndex inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [self.toDosTableView endUpdates];
                    
                }];
            }
        }
    }
}

#pragma mark - Shake Motion Detection

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        
        NSMutableArray *toDosToBeDeleted = [[NSMutableArray alloc] init];
        int row = 0;
        
        for (TDToDo *todo in self.toDosDataSource) {
            if (!todo.active) {
                [toDosToBeDeleted addObject:todo];
            }
            row++;
        }
        
        [self.toDosDataSource removeObjectsInArray:toDosToBeDeleted];
        [self removeNotificacoesFromToDo:toDosToBeDeleted];
        [self.toDosTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark Table View Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isFiltering ? self.filteredToDosDataSource.count : self.toDosDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TDToDoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    TDToDo *todo;
    
    if (self.isFiltering) {
        todo = [self.filteredToDosDataSource objectAtIndex:indexPath.row];
    } else {
        todo = [self.toDosDataSource objectAtIndex:indexPath.row];
    }
    
    [cell.priorityIcon setHidden:YES];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.toDoLabel setFont:[UIFont fontWithName:[TDGlobalConfiguration fontName] size:[TDGlobalConfiguration fontSize]]];
    [cell.toDoLabel setTextColor:[TDGlobalConfiguration fontColor]];
        
    if (todo.active) {
        [cell.priorityIcon setHidden:!todo.priority];
        [cell.toDoLabel setAttributedText:nil];
        [cell.toDoLabel setText:todo.description];
    } else {
        [cell.toDoLabel setText:nil];
        [cell.toDoLabel setAttributedText:[self strikeThroughText:todo.description]];
    }
    
//    cell.toDoLabel.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    
    TDToDo *toDo = [self.toDosDataSource objectAtIndex:indexPath.row];
    
    if (toDo.active) {
        [toDo togglePriority];
    }
    
    [self.toDosTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark View delegates
CAGradientLayer *grad;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Adding swipe gesture: right direction
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Arrumar malas"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Levar TV no conserto"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Levar carro na revisão"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Aprender guitarra"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Terminar Bioshock pela 2a vez"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Deixar esse App do caralho"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Terminar de ler artigos de IA"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Terminar de ler capítulo do livro de IA"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Comprar CDs novos"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Comprar livros novos"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Comprar filmes novos"]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Terminar \"NHK ni Youkoso!\""]];
//    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Virar mestre do mundo"]];
//
//    for (int i = 0; i < 1000; i++) {
//        [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:[NSString stringWithFormat:@"Placeholder Todo %d", i]]];
//    }
    
    self.toDosTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.navigationController.navigationBar setBarTintColor:[TDGlobalConfiguration navigationBarCoor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:[TDGlobalConfiguration fontName] size:[TDGlobalConfiguration fontSizeBig]], NSFontAttributeName, [TDGlobalConfiguration fontColor] , NSForegroundColorAttributeName, Nil]];
    [self.navigationController.navigationBar setTintColor:[TDGlobalConfiguration fontColor]];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeft:)];
    panRecognizer.delegate = self;
    [self.toDosTableView addGestureRecognizer:panRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [longPressRecognizer setNumberOfTouchesRequired:1];
    [self.toDosTableView addGestureRecognizer:longPressRecognizer];
    [self.toDosTableView setBackgroundColor:[TDGlobalConfiguration controlBackgroundColor]];
    [self.toDosTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.searchAndAddTextField setFont:[UIFont fontWithName:[TDGlobalConfiguration fontName] size:[TDGlobalConfiguration fontSize]]];
    [self.searchAndAddTextField setTextColor:[TDGlobalConfiguration fontColor]];
    
    grad = [TDGlobalConfiguration gradientLayer];
    grad.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view.layer insertSublayer:grad atIndex:0];
    
    //parte para notificacao
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES];
    [self.toDosTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self hideKeyboard];
    
    TDEditToDoViewController *editView = [segue destinationViewController];
    
    NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:_cellLocation];

    editView.toDo = self.isFiltering ? [self.filteredToDosDataSource objectAtIndex:indexPath.row] : [self.toDosDataSource objectAtIndex:indexPath.row];
}

#pragma mark - Parte da notificacao por local

- (void) freshLatitudeLongitude :(SL_Localidades*)local{
    self.location = self.locationManager.location;
    
    [self.locationManager startMonitoringForRegion:local.regiao];
}

-(void)removeNotificacoesFromToDo :(NSMutableArray*)toDosToRemove
{
    for(TDToDo* toDo in toDosToRemove){
        TDNotificationConfiguration *reminder = [[TDNotificationConfiguration alloc]init];
        int count = [toDo reminders].count;
        for(int i=0;i<count;i++){
            //sempre será removido um reminder da lista, por isso é sempre 0.
            reminder = [toDo reminders][0];
            if(reminder.type == Location){
                [toDo removeNotificationConfigurationBasedOnLocation: 0];
            }
            if(reminder.type == DateTime){
                [toDo removeNotificationConfigurationBasedOnLocation: 0];
                for(int j=0; j<reminder.arrayLocalNotifications.count;j++){
                    [[UIApplication sharedApplication] cancelLocalNotification: reminder.arrayLocalNotifications[j]];
                }
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //terá que ser visto qual é a data para saber colocar no fireDate e também ver se já passou a data
    //para cancelar o region monitoring
    
    NSMutableArray *arrayToDos = [[SL_armazenaDados sharedArmazenaDados]listToDosRegs];
    NSMutableArray *arrayRemoveToDos = [[NSMutableArray alloc]init];
    NSMutableArray *arrayRemoveReminders = [[NSMutableArray alloc]init];
    
    for (TD_RegiaoToDo *RegiaoToDo in arrayToDos) {
        if([[RegiaoToDo regionIdentifier]isEqualToString:region.identifier]){
            for(TDToDo* toDo in [RegiaoToDo listToDos] ){
                for(TDNotificationConfiguration* reminder in [toDo reminders]){
                    if([reminder.location.regiao.identifier isEqualToString:region.identifier]){
                        //essa parte é sem cláusula de horário
                        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                        NSDate *currentDate = [NSDate date];
                        NSDate *fireDate = nil;
                        
                        [dateComponents setSecond: 1];
                        
                        fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                                                 toDate:currentDate
                                                                                options:0];
                        
                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                        notification.fireDate = [NSDate date];
                        NSTimeZone* timezone = [NSTimeZone defaultTimeZone];
                        notification.timeZone = timezone;
                        notification.alertBody = [toDo description];
                        notification.alertAction = @"Analisar notificação";
                        notification.soundName = @"alarm.wav";
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                        
                        //aqui vai precisar para quando tiver cláusula de horário
                        //[[[SL_armazenaDados sharedArmazenaDados]dicNotsRegs] setObject:notification forKey:region.identifier];
                        [arrayRemoveReminders addObject:reminder];
                        [arrayRemoveToDos addObject:toDo];
                    }
                }
                for(TDNotificationConfiguration* reminder in arrayRemoveReminders){
                    [[toDo reminders] removeObject:reminder];
                }
            }
        }
        for(TDToDo* toDo in arrayRemoveToDos){
            [RegiaoToDo removeToDo:toDo];
        }
        if(![RegiaoToDo hasToDo]){
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //cancelar a partir da region, ver se funciona quando o didEnterRegion não foi feito antes
    for(int i=0;i<[[[SL_armazenaDados sharedArmazenaDados] listLocalidades]count];i++){
        SL_Localidades* locAux = [[SL_armazenaDados sharedArmazenaDados]listLocalidades][i];
        if([locAux.regiao.identifier isEqualToString : region.identifier]){
            id object = [[[SL_armazenaDados sharedArmazenaDados]dicNotsRegs] objectForKey:region.identifier];
            if(object){
                int index = [[UIApplication sharedApplication]indexOfAccessibilityElement:object];
                if(index>=0){
                    [[UIApplication sharedApplication] cancelLocalNotification: [[[SL_armazenaDados sharedArmazenaDados]dicNotsRegs] objectForKey:region.identifier]];
                }
            }
        }
    }
}


-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Now monitoring for %@", region.identifier);
}
@end
