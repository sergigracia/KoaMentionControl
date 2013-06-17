//
//  KoaMentionControl.m
//  KoaMentionControl
//
//  Created by Sergi Gracia on 20/03/13.
//  Copyright (c) 2013 Sergi Gracia. All rights reserved.
//

#import "KoaMentionControl.h"

#define tableMarginTop 36

@interface KoaMentionControl ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, strong) NSMutableDictionary *itemsDictionary;
@property (nonatomic, strong) NSMutableArray *itemsKeysFiltered;
@property (nonatomic, strong) NSMutableArray *itemsKeysFilteredOld;

@property (nonatomic) NSRange currentRange;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect currentKeyboardFrame;
@property (nonatomic) BOOL isAMentionWord;
@property (nonatomic) BOOL isMentionTableVisible;
@property (nonatomic) BOOL isKeyboardVisible;

@property (nonatomic) NSOperationQueue *orderQueue;

@end

@implementation KoaMentionControl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Init queue
    self.orderQueue = [[NSOperationQueue alloc] init];
    [self.orderQueue setMaxConcurrentOperationCount:1];
    
    [self.shadowView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shadow.png"]]];
    
    [self.view setAlpha:0];
    [self.view setFrame:CGRectMake(0, 60, self.parentView.frame.size.width, self.view.frame.size.height)];
    
    [self.parentView addSubview:self.view];
    
    self.isAMentionWord = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setters

- (void)setMentionTextView:(UITextView *)textView
{
    self.textView = textView;
    self.originalFrame = textView.frame;
}

- (void)setMentionParentView:(UIView *)parentView
{
    self.parentView = parentView;
}

- (void)setMentionParentViewController:(UIViewController *)parentViewController
{
    self.parentViewController = parentViewController;
}

- (void)setMentionItemsDictionary:(NSMutableDictionary *)itemsDictionary
{
    self.itemsDictionary = [NSMutableDictionary dictionaryWithDictionary:itemsDictionary];
    self.itemsKeysFiltered = [NSMutableArray arrayWithArray:itemsDictionary.allKeys];
}

#pragma mark - TextView

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    //NSLog(@"Selection changed (%d)", [textView selectedRange].location);
    
    NSRange range = [textView selectedRange];
    
    NSString *mentionWord = @"";

    NSMutableCharacterSet *letters = [NSMutableCharacterSet characterSetWithCharactersInString:@"._-"];
    [letters formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    self.isAMentionWord = NO;
    
    //Check if we are in a mention word
    //Search all mention-word
    for (int i = range.location-1; i >= 0; i=i-1) {
        //NSLog(@"// %@", [textView.text substringWithRange:NSMakeRange(i, 1)]);
        
        NSString *currentChar = [textView.text substringWithRange:NSMakeRange(i, 1)];
        
        if ([currentChar isEqualToString:@"@"]) {
            
            NSString *previousChar = [textView.text substringWithRange:NSMakeRange(i-1, 1)];
            
            //To start mention is needed a withe space before the '@'
            if ([previousChar isEqualToString:@" "] || [previousChar isEqualToString:@"\n"]) {
                self.isAMentionWord = YES;
                mentionWord = [textView.text substringWithRange:NSMakeRange(i, range.location-i)];
                //self.currentRange = NSMakeRange(i, range.location-i+1);
            }else{
                self.isAMentionWord = NO;
            }
            
            break;
        }
        
        if(![letters characterIsMember:[currentChar characterAtIndex:0]]) {
            // This is not a letter
            self.isAMentionWord = NO;
            break;
        }
    }
    
    [self textViewDidChange:self.textView];
    
    if (self.isAMentionWord) {
        [self filterContentForSearchText:mentionWord];
    }
    
    //NSLog(@"Is a mention word? %@ !", (self.isAMentionWord==YES?@"YES":@"NO"));
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //NSLog(@"Text range(%d, %d) text(%@)", range.length, range.location, text);
    
    NSString *mentionWord = @"";
    
    NSMutableCharacterSet *letters = [NSMutableCharacterSet characterSetWithCharactersInString:@"._-"];
    [letters formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    if ([text isEqualToString:@"@"]) {
        //Starting mention
        
        NSString *previousChar = @" ";
        if (range.location > 0) {
            previousChar = [textView.text substringWithRange:NSMakeRange(range.location-1, 1)];
        }
        
        //To start mention is needed a withe space before the '@'
        if ([previousChar isEqualToString:@" "] || [previousChar isEqualToString:@"\n"]) {
            self.isAMentionWord = YES;
            mentionWord = @"@";
        }else{
            self.isAMentionWord = NO;
        }
        
        self.currentRange = NSMakeRange(range.location, 1);

    }else if (range.location == 0){
        //First char of textview
        self.isAMentionWord = NO;
        
    }else if(![text isEqualToString:@""] && ![letters characterIsMember:[text characterAtIndex:0]]) {
        // This is not a letter
        self.isAMentionWord = NO;
        
    }else{
        //Search all mention-word
        for (int i = range.location-1; i >= 0; i=i-1) {
            //NSLog(@"// %@", [textView.text substringWithRange:NSMakeRange(i, 1)]);
            
            NSString *currentChar = [textView.text substringWithRange:NSMakeRange(i, 1)];
            
            if ([currentChar isEqualToString:@"@"]) {
                
                NSString *previousChar = @" ";
                if (i > 0) {
                    previousChar = [textView.text substringWithRange:NSMakeRange(i-1, 1)];
                }
                
                //To start mention is needed a withe space before the '@'
                if ([previousChar isEqualToString:@" "] || [previousChar isEqualToString:@"\n"]) {
                    self.isAMentionWord = YES;
                    mentionWord = [[textView.text substringWithRange:NSMakeRange(i, range.location-i)] stringByAppendingString:text];
                    
                    if([text isEqualToString:@""]){
                        //User is deleting
                        self.currentRange = NSMakeRange(i, range.location-i);
                    }else{
                        self.currentRange = NSMakeRange(i, range.location-i+1);
                    }
                }else{
                    self.isAMentionWord = NO;
                }
                
                break;
            }
            
            if(![letters characterIsMember:[currentChar characterAtIndex:0]]) {
                // This is not a letter
                self.isAMentionWord = NO;
                break;
            }
        }
    }
    
    if (self.isAMentionWord) {
        [self filterContentForSearchText:mentionWord];
    }
    
    //NSLog(@"Is a mention word? %@ !", (self.isAMentionWord==YES?@"YES":@"NO"));
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.isAMentionWord) {
        
        if (self.view.alpha == 0) {
            //Show table
            [self showTable];
        }
    
    }else{
        if (self.view.alpha == 1) {
            //Hide Table
            [self hideTable];
        }
    }
}

#pragma mark - TableView

- (void)showTable
{
    if ([self.parentViewController respondsToSelector:@selector(showMenu)]) {
        [self.parentViewController performSelector:@selector(showMenu)];
    }
    
    [self setIsMentionTableVisible:YES];
    [self resizeTextView];
}

- (void)hideTable
{
    if ([self.parentViewController respondsToSelector:@selector(hideMenu)]) {
        [self.parentViewController performSelector:@selector(hideMenu)];
    }
    
    [self setIsMentionTableVisible:NO];
    [self resizeTextViewToOriginalPosition];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"%d table items", self.itemsKeysFiltered.count);
    return self.itemsKeysFiltered.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KoaMentionControlItemCell *cell = (KoaMentionControlItemCell *)[tableView dequeueReusableCellWithIdentifier:@"KoaMentionControlItemCell"];

    //Init always the cell layout
    //if(cell == nil)
    //{
        // create cell if non are reusable
        [[NSBundle mainBundle] loadNibNamed:@"KoaMentionControlItemCell" owner:self options:nil];
        cell = self.itemCell;
        self.itemCell = nil;
        [cell.value setHidden:NO];
        [cell.description setHidden:NO];
        [cell.image setHidden:NO];
    //}
    
    if (indexPath.row == 0) {
        [cell applyFontBold];
    }else{
        [cell applyFont];
    }
    
    if ([self.itemsDictionary objectForKey:[self.itemsKeysFiltered objectAtIndex:indexPath.row]]) {
        
        KoaMentionControlItemObject *oneItem = (KoaMentionControlItemObject*)[self.itemsDictionary objectForKey:[self.itemsKeysFiltered objectAtIndex:indexPath.row]];
        
        if (oneItem.description) {
            [cell.description setText:oneItem.description];            
        }
        
        if (![oneItem.image isEqualToString:@""]) {
            [cell setImageCell:oneItem.image];
            
        }else{
            [cell.image setHidden:YES];
            [cell.description setFrame:CGRectMake(cell.description.frame.origin.x, cell.description.frame.origin.y,
                                            cell.description.frame.size.width + cell.image.frame.size.width + cell.value.frame.origin.x,
                                            cell.description.frame.size.height)];
        }
        
    }else{
        [cell.description setText:@""];
        
        [cell.description setHidden:YES];
        [cell.image setHidden:YES];
    
        [cell.value setFrame:CGRectMake(cell.value.frame.origin.x, cell.value.frame.origin.y,
                                        cell.frame.size.width - cell.value.frame.origin.x * 2,
                                        cell.value.frame.size.height)];
    }
    
    [cell.value setText:[self.itemsKeysFiltered objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *valueSelected = [self.itemsKeysFiltered objectAtIndex:indexPath.row];
    
    //NSLog(@"Selected: %@ (Range: location(%lu) length(%lu))", valueSelected, (unsigned long)self.currentRange.location, (unsigned long)self.currentRange.length);
    
    valueSelected = [valueSelected stringByAppendingString:@" "];
    
    //Put username in text (ignore text messages inside table)
    if ([[valueSelected substringToIndex:1] isEqualToString:@"@"]) {
        self.textView.text = [self.textView.text stringByReplacingCharactersInRange:self.currentRange withString: valueSelected];
        [self hideTable];
    }
}

#pragma mark - Search items

- (void)filterContentForSearchText:(NSString*)searchText
{
    [self.orderQueue addOperationWithBlock:^{
        [self blockFilterContentForSearchText:searchText];
    }];
}

- (void)blockFilterContentForSearchText:(NSString*)searchText
{
    //NSLog(@"Search Text: %@", searchText);
    
    if (self.itemsKeysFiltered.count > 0) {
        
        //Save old keys filtered to show if there aren't results
        if (self.itemsKeysFiltered.count > 0) {
            self.itemsKeysFilteredOld = [NSMutableArray arrayWithArray:self.itemsKeysFiltered];
        }
        
        [self.itemsKeysFiltered removeAllObjects]; // First clear the filtered array.
    }
	
    if ([searchText isEqualToString:@"@"]) {
        self.itemsKeysFiltered = [NSMutableArray arrayWithArray:self.itemsDictionary.allKeys];
    }else{
    	for (NSString *oneValue in self.itemsDictionary.allKeys)
        {
            NSRange range = [oneValue rangeOfString:searchText options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
            if (range.location != NSNotFound) {
                [self.itemsKeysFiltered addObject:oneValue];
                continue;
            }
            
            //Compare full name
            KoaMentionControlItemObject *oneItem = (KoaMentionControlItemObject*)[self.itemsDictionary objectForKey:oneValue];
            
            NSString *fullname = [NSString stringWithString:oneItem.description];
            NSString *searchTextCleaned = [searchText stringByReplacingOccurrencesOfString:@"@" withString:@""];
            NSRange range2 = [fullname rangeOfString:searchTextCleaned options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
            if (range2.location != NSNotFound) {
                [self.itemsKeysFiltered addObject:oneValue];
            }
        }
    }
    
    [self orderFilteredArrayWithSearchText:searchText];
}

- (void)orderFilteredArrayWithSearchText:(NSString *)searchText
{
    //NSLog(@"Start %@", searchText);
    NSMutableArray *descriptionsArray = [[NSMutableArray alloc] init];
    NSMutableArray *finalKeysArray = [[NSMutableArray alloc] init];
    NSMutableArray *itemsKeysFilteredLocal = [NSMutableArray arrayWithArray:self.itemsKeysFiltered];
    
    //Get descriptions of filtered objects
    for (NSString *oneValue in itemsKeysFilteredLocal) {
        
        KoaMentionControlItemObject *oneItem = (KoaMentionControlItemObject*)[self.itemsDictionary objectForKey:oneValue];
        [descriptionsArray addObject:oneItem.description];
    }
    
    //Order descriptions
    [descriptionsArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    if ([searchText isEqualToString:@"@"] && [self.itemsDictionary objectForKey:@"@all"]) {
        [finalKeysArray addObject:@"@all"];
    }
    
    //Reorder keys with ordered descriptions
    for (NSString *oneDescription in descriptionsArray) {
        for (NSString *oneValue in itemsKeysFilteredLocal) {
            //NSLog(@"Value: %@", oneValue);
            //Jump '@all' value
            if ([searchText isEqualToString:@"@"] && [oneValue isEqualToString:@"@all"]) {
                continue;
            }
            //[NSThread sleepForTimeInterval:0.01];
            KoaMentionControlItemObject *oneItem = (KoaMentionControlItemObject*)[self.itemsDictionary objectForKey:oneValue];
            
            if ([oneItem.description isEqualToString:oneDescription]) {
                [finalKeysArray addObject:oneValue];
                break;
            }
        }
    }
    
    //No results?
    if (finalKeysArray.count == 0) {
        NSString *messageNotFound = NSLocalizedString(@"No matches found. Did you mean:", nil);
        [finalKeysArray addObject: messageNotFound];
        for (NSString *oneValue in self.itemsKeysFilteredOld) {
            if (![oneValue isEqualToString:messageNotFound]) {
                [finalKeysArray addObject:oneValue];                
            }
        }
    }
    
    self.itemsKeysFiltered = [NSMutableArray arrayWithArray:finalKeysArray];
    
    //It's necessary to refresh the ui from mainThread
    [self.mentionTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    //NSLog(@"End %@", searchText);
}

#pragma mark - Keyboard

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    //Final keyboard size
    [self setCurrentKeyboardFrame:[self.view convertRect:keyboardEndFrame toView:nil]];
    
    [self resizeTextView];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    [self setIsKeyboardVisible:YES];
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self setIsKeyboardVisible:NO];
    [self moveTextViewForKeyboard:aNotification up:NO];
}

#pragma mark - Views resizer

- (void)resizeTextView
{
    CGPoint cursorPosition = [self.textView caretRectForPosition:self.textView.selectedTextRange.start].origin;

    if (self.isMentionTableVisible) {
        //Scroll mention table to the top
        [self.mentionTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    //Set alpha
    [self.view setAlpha: 1 * self.isMentionTableVisible];
    
    //Set mention table view frame
    CGRect newMentionViewFrame = CGRectMake(0, tableMarginTop, self.parentView.frame.size.width, self.parentView.frame.size.height - self.currentKeyboardFrame.size.height * (self.isKeyboardVisible?1:-1) - tableMarginTop);
    [self.view setFrame: newMentionViewFrame];
    
    //Set textview frame
    CGRect newTextViewFrame = self.textView.frame;
    
    newTextViewFrame.origin.y = 0;
    
    //Keyboard + Mentio Table heights
    newTextViewFrame.size.height =  self.parentView.frame.size.height;
    
    //Add keyboard height
    newTextViewFrame.size.height -= self.currentKeyboardFrame.size.height * (self.isKeyboardVisible?1:0);
    
    //Add mention table height
    newTextViewFrame.size.height -= newMentionViewFrame.size.height * (self.isMentionTableVisible?1:0);
    
    [self.textView setFrame:newTextViewFrame];

    //Scroll to the cursor zone
    [self.textView scrollRectToVisible:CGRectMake(cursorPosition.x, cursorPosition.y-20, 10, 40) animated:NO];
    
    [UIView commitAnimations];
}

- (void)resizeTextViewToOriginalPosition
{
    CGPoint cursorPosition = [self.textView caretRectForPosition:self.textView.selectedTextRange.start].origin;
    
    if (self.isMentionTableVisible) {
        //Scroll mention table to the top
        [self.mentionTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    //Set alpha
    [self.view setAlpha: 1 * self.isMentionTableVisible];
    
    //Set mention table view frame
    CGRect newMentionViewFrame = CGRectMake(0, tableMarginTop, self.parentView.frame.size.width, self.parentView.frame.size.height - self.currentKeyboardFrame.size.height * (self.isKeyboardVisible?1:-1) - tableMarginTop);
    [self.view setFrame: newMentionViewFrame];
    
    [self.textView setFrame:self.originalFrame];
    
    //Scroll to the cursor zone
    [self.textView scrollRectToVisible:CGRectMake(cursorPosition.x, cursorPosition.y-20, 10, 40) animated:NO];
    
    [UIView commitAnimations];
}

@end












