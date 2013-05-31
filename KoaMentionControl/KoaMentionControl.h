//
//  KoaMentionControl.h
//  KoaMentionControl
//
//  Created by Sergi Gracia on 20/03/13.
//  Copyright (c) 2013 Sergi Gracia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KoaMentionControlItemCell.h"

typedef struct
{
    //Using __unsafe_unretained because ARC doesn't support structs
    __unsafe_unretained NSString *description;
    __unsafe_unretained NSString *image;
} item;

@interface KoaMentionControl : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *shadowView;
@property (nonatomic, weak) IBOutlet UITableView *mentionTableView;
@property (nonatomic, weak) IBOutlet KoaMentionControlItemCell *itemCell;

//Setters
- (void)setMentionTextView:(UITextView *)textView;
- (void)setMentionParentView:(UIView *)parentView;
- (void)setMentionItemsDictionary:(NSMutableDictionary *)itemsDictionary;

//Textview delegate methods
- (void)textViewDidChangeSelection:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(UITextView *)textView;

@end
