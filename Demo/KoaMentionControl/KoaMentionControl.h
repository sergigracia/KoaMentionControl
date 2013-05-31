//
//  KoaMentionControl.h
//  KoaMentionControl
//
//  Created by Sergi Gracia on 20/03/13.
//  Copyright (c) 2013 Sergi Gracia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KoaMentionControlItemCell.h"
#import "KoaMentionControlItemObject.h"

@interface KoaMentionControl : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *shadowView;
@property (nonatomic, weak) IBOutlet UITableView *mentionTableView;
@property (nonatomic, weak) IBOutlet KoaMentionControlItemCell *itemCell;

- (void)setMentionTextView:(UITextView *)textView;
- (void)setMentionParentView:(UIView *)parentView;
- (void)setMentionParentViewController:(UIViewController *)parentViewController;
- (void)setMentionItemsDictionary:(NSMutableDictionary *)itemsDictionary;

//Textview delegate
- (void)textViewDidChangeSelection:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(UITextView *)textView;

@end
