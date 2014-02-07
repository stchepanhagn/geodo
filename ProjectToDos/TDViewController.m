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
#import "TDToDosCell.h"

@interface TDViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchAndAddTextField;
@property (weak, nonatomic) IBOutlet UITableView *toDosTableView;
@property (strong, nonatomic) NSMutableArray *toDosDataSource;
@property (strong, nonatomic) NSMutableArray *filteredToDosDataSource;
@property (nonatomic) BOOL isFiltering;

@end

@implementation TDViewController
- (IBAction)editToDoDescription:(UITextField *)sender {
    [self resignFirstResponder];
    
    if (![sender.text isEqualToString:@""]) {
        TDToDo *toDo = [self.toDosDataSource objectAtIndex:sender.tag];
        
        toDo.description = sender.text;
    }
}

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

- (IBAction)onTheFlySearch:(UITextField *)sender {
    NSLog(@"Search attempt for string: %@", sender.text);
    self.isFiltering = YES;
    [self.filteredToDosDataSource removeAllObjects];
    [self.toDosTableView reloadData];
    
    for (TDToDo *todo in self.toDosDataSource) {
        if (sender.text.length <= todo.description.length){
            NSString *initials = [todo.description substringToIndex:sender.text.length];
            if ([initials isEqualToString:sender.text])
            {
                [self.filteredToDosDataSource addObject:todo];
                [self.toDosTableView reloadData];
            }
        }
    }
}

- (IBAction)addNewToDo:(UITextField *)sender {
    if ([sender.text isEqualToString:@""])
        return;
    
    self.isFiltering = NO;
    
    [self.toDosTableView reloadData];
    
    [self.toDosTableView beginUpdates];
    
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    TDToDo *newTodo = [[TDToDo alloc] initWithDescription:sender.text];

    [newList addObject:newTodo];
    
    for (TDToDo *todo in self.toDosDataSource) {
        [newList addObject:todo];
    }
    
    self.toDosDataSource = newList;
    
    NSArray *paths = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.toDosTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    
    [self.toDosTableView endUpdates];

    NSLog(@"Added New ToDo Entry: %@", [self.toDosDataSource firstObject]);
    [sender setText:@""];
}

UITableViewCell *longPressSelectedCell;
TDToDo *longPressSelectedToDo;
NSIndexPath *longPressSelectedIndexPath;
CGPoint originalCenter;
- (void)longPress:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"Long press began at: %@.", NSStringFromCGPoint([gesture locationInView:self.toDosTableView]));
        [self resignFirstResponder];
        CGPoint cellLocation = [gesture locationInView:self.toDosTableView];
        longPressSelectedIndexPath =  [self.toDosTableView indexPathForRowAtPoint:cellLocation];
        longPressSelectedToDo = [self.toDosDataSource objectAtIndex:longPressSelectedIndexPath.row];
        originalCenter = [self.toDosTableView cellForRowAtIndexPath:longPressSelectedIndexPath].center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint cellLocation = [gesture locationInView:self.toDosTableView];
        
        if (cellLocation.y > (longPressSelectedCell.frame.size.height))
        {
            NSIndexPath *newIndexPath =  [self.toDosTableView indexPathForRowAtPoint:cellLocation];
            
            if (newIndexPath && newIndexPath.row != longPressSelectedIndexPath.row) {
            
                [self.toDosTableView beginUpdates];
                [self.toDosTableView deleteRowsAtIndexPaths:@[longPressSelectedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                if (newIndexPath.row > longPressSelectedIndexPath.row) {

                    [self.toDosDataSource insertObject:longPressSelectedToDo atIndex:newIndexPath.row+1];
                    [self.toDosDataSource removeObjectAtIndex:longPressSelectedIndexPath.row];
                } else {

                    [self.toDosDataSource removeObjectAtIndex:longPressSelectedIndexPath.row];
                    [self.toDosDataSource insertObject:longPressSelectedToDo atIndex:newIndexPath.row];
                }
                
                [self.toDosTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];

                
                [self.toDosTableView endUpdates];
                
                longPressSelectedIndexPath =  [self.toDosTableView indexPathForRowAtPoint:cellLocation];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Adding swipe gesture: right direction
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Comprar pao"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Arrumar malas"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Levar TV no conserto"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Aprender guitarra"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Terminar Bioshock pela 2a vez"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Deixar esse App do caralho"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Terminar de ler artigos de IA"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Terminar de ler capítulo do livro de IA"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Comprar CDs novos"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Comprar livros novos"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Agendar revisão do carro"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Virar mestre do mundo"]];
    [self.toDosDataSource addObject:[[TDToDo alloc] initWithDescription:@"Pesquisa de preço - Monitor IPS 27\""]];
    
    UISwipeGestureRecognizer *swipeRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeRec setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.toDosTableView addGestureRecognizer:swipeRec];
    
    // Adding swipe gesture: left direction
    /*
    swipeRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeRec setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.toDosTableView addGestureRecognizer:swipeRec];*/
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeft:)];
    panRecognizer.delegate = self;
    [self.toDosTableView addGestureRecognizer:panRecognizer];
    
    UILongPressGestureRecognizer *longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [longPressRec setNumberOfTouchesRequired:1];
    [self.toDosTableView addGestureRecognizer:longPressRec];

    
    [self.toDosTableView setBackgroundColor:[UIColor clearColor]];
}

#warning move "handle pan"
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self.view superview]];
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

CGPoint _originalCenter;
BOOL _deleteOnDragRelease;

-(void)panLeft:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.toDosTableView];
    NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.toDosTableView cellForRowAtIndexPath:indexPath];
    // 1
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // if the gesture has just started, record the current centre location
        _originalCenter = cell.center;
    }
    
    // 2
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // translate the center
        CGPoint translation = [recognizer translationInView:cell];
        cell.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
        // determine whether the item has been dragged far enough to initiate a delete / complete
        _deleteOnDragRelease = cell.frame.origin.x < -cell.frame.size.width / 2;
        
    }
    
    // 3
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, cell.frame.origin.y,
                                          cell.bounds.size.width, cell.bounds.size.height);
        if (!_deleteOnDragRelease) {
            // if the item is not being deleted, snap back to the original location
            [UIView animateWithDuration:0.2
                             animations:^{
                                 cell.frame = originalFrame;
                             }
             ];
        } else {
            NSLog(@"Swiped left");
            CGPoint location = [recognizer locationInView:self.toDosTableView];
            
            NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:location];
            
            if (indexPath) {
                [self performSegueWithIdentifier:@"DetailToDo" sender:recognizer];
            }
        }
    }
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
    TDEditToDoViewController *editView = [segue destinationViewController];

    NSLog(@"Swiped left");
    CGPoint location = [sender locationInView:self.toDosTableView];
    
    NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:location];


    if (self.isFiltering) {
        editView.toDo = [self.filteredToDosDataSource objectAtIndex:indexPath.row];
    } else {
        editView.toDo = [self.toDosDataSource objectAtIndex:indexPath.row];
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
    if (motion == UIEventSubtypeMotionShake)
    {
        // User was shaking the device. Post a notification named "shake."
        NSLog(@"Shake detected. Disposing of completed tasks.");
        NSMutableArray *toDosToBeDeleted = [[NSMutableArray alloc] init];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        int pos = 0;
        
        for (TDToDo *todo in self.toDosDataSource) {
            if (!todo.active) {
                [toDosToBeDeleted addObject:todo];
                [indexPaths addObject:[NSIndexPath indexPathForRow:pos inSection:0]];
                
            }
            pos++;
        }
        
        [self.toDosDataSource removeObjectsInArray:toDosToBeDeleted];
        //[self.toDosTableView reloadData];
        
        [self.toDosTableView beginUpdates];
        [self.toDosTableView deleteRowsAtIndexPaths:indexPaths
                                       withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.toDosTableView endUpdates];
    }
}

#pragma mark Table View Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFiltering) {
        return self.filteredToDosDataSource.count;
    } else {
        return self.toDosDataSource.count;
    }
}

- (NSAttributedString *)strikeThroughText:(NSString *)text
{
    NSDictionary* attributes = @{
                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                 };
    
    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attrText;
}

- (void)swipeRight:(UISwipeGestureRecognizer *)gesture
{
    NSLog(@"Swiped right");
    CGPoint location = [gesture locationInView:self.toDosTableView];
    NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:location];
    TDToDo *toDo = [self.toDosDataSource objectAtIndex:indexPath.row];
    [toDo toggleActive];
    
    if (toDo.active) {
//        [self sendToDoToTopOfNonPriorityList:toDo CurrentlyAtIndex:indexPath];
        NSIndexPath *newIndexPath = [self getFirstNonPriorityIndex];
        
        [UIView animateWithDuration:.6 animations:^{
            [self.toDosTableView beginUpdates];
            
            [self.toDosDataSource removeObjectAtIndex:indexPath.row];
            [self.toDosDataSource insertObject:toDo atIndex:newIndexPath.row];
            
            [self.toDosTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            [self.toDosTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.toDosTableView endUpdates];
        }];
    } else {
    
        [UIView animateWithDuration:.6 animations:^{
//            [self.toDosTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
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

- (void)swipeLeft:(UISwipeGestureRecognizer *)gesture
{
    NSLog(@"Swiped left");
    CGPoint location = [gesture locationInView:self.toDosTableView];
    
    NSIndexPath *indexPath = [self.toDosTableView indexPathForRowAtPoint:location];

    if (indexPath) {
        [self performSegueWithIdentifier:@"DetailToDo" sender:gesture];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TDToDosCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    TDToDo *todo;
    
    if (self.isFiltering) {
        todo = [self.filteredToDosDataSource objectAtIndex:indexPath.row];
    }
    else {
        todo = [self.toDosDataSource objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    if (todo.active) {
        if (todo.priority) {
            cell.textLabel.textColor = [UIColor redColor];
        }
        [cell.textLabel setText:todo.description];
    } else {

        cell.textLabel.attributedText = [self strikeThroughText:todo.description];
    }
    
    cell.textLabel.tag = indexPath.row;
    
    return cell;
}

- (NSIndexPath *)getFirstNonPriorityIndex
{
    int index = 0;
    for (TDToDo *toDo in self.toDosDataSource) {
        if (toDo.priority) {
            index++;
        }
    }
    return [NSIndexPath indexPathForRow:index inSection:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDToDo *toDo = [self.toDosDataSource objectAtIndex:indexPath.row];
    
    if (toDo.active) {
        [toDo togglePriority];
        
        if (toDo.priority) {
        
            [UIView animateWithDuration:.6 animations:^{
                [self.toDosTableView beginUpdates];
                
                [self.toDosDataSource removeObjectAtIndex:indexPath.row];
                [self.toDosDataSource insertObject:toDo atIndex:0];
                
                [self.toDosTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.toDosTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                [self.toDosTableView endUpdates];
            }];
        } else {
            
            NSIndexPath *newIndexPath = [self getFirstNonPriorityIndex];
            
            [UIView animateWithDuration:.6 animations:^{
                [self.toDosTableView beginUpdates];
                
                [self.toDosDataSource removeObjectAtIndex:indexPath.row];
                [self.toDosDataSource insertObject:toDo atIndex:newIndexPath.row];
                
                [self.toDosTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.toDosTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                [self.toDosTableView endUpdates];
            }];
        }
    }
}

@end
