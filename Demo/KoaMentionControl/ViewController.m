//
//  ViewController.m
//  KoaMentionControl
//
//  Created by Sergi Gracia on 20/03/13.
//  Copyright (c) 2013 Sergi Gracia. All rights reserved.
//

#import "ViewController.h"
#import "KoaMentionControl.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) KoaMentionControl *KoaMentionControl;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setTitle:@"Mention Demo"];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.textView setFont:[UIFont fontWithName:@"DroidSans" size:13]];
    
    self.KoaMentionControl = [[KoaMentionControl alloc] initWithNibName:@"KoaMentionControl" bundle:nil];
    
    [self.KoaMentionControl setMentionTextView:self.textView];
    [self.KoaMentionControl setMentionParentView:self.view];
    //[self.textView setDelegate:self.KoaMentionControl];
    [self.textView setDelegate:self];

    //Set items list
    
    item oneItem1;
    oneItem1.description = @"All people in project";
    oneItem1.image = @"";
    
    item oneItem2;
    oneItem2.description = @"Polina Flegontovna";
    oneItem2.image = @"url";
    
    item oneItem3;
    oneItem3.description = @"Marcos Medina";
    oneItem3.image = @"url";

    item oneItem4;
    oneItem4.description = @"Sergi Gracia";
    oneItem4.image = @"url";
    
    item oneItem5;
    oneItem5.description = @"Wa Sabi";
    oneItem5.image = @"url";

    NSMutableDictionary *itemsList = [[NSMutableDictionary alloc] initWithObjectsAndKeys:   [NSValue value:&oneItem1 withObjCType:@encode(item)], @"@all",
                                                                                            [NSValue value:&oneItem2 withObjCType:@encode(item)], @"@flegontovna",
                                                                                            [NSValue value:&oneItem3 withObjCType:@encode(item)], @"@marcosmedina",
                                                                                            [NSValue value:&oneItem4 withObjCType:@encode(item)], @"@sgracia",
                                                                                            [NSValue value:&oneItem5 withObjCType:@encode(item)], @"@w2a.s-a_bi", nil];
    [self.KoaMentionControl setMentionItemsDictionary:itemsList];
}
- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self.KoaMentionControl selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.KoaMentionControl selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.KoaMentionControl];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Textview delegate

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self.KoaMentionControl textViewDidChangeSelection:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [self.KoaMentionControl textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.KoaMentionControl textViewDidChange:textView];
}


@end

