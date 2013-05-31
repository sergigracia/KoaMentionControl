//
//  KoaMentionControlItemCell.m
//  KoaMentionControl
//
//  Created by Sergi Gracia on 21/03/13.
//  Copyright (c) 2013 Sergi Gracia. All rights reserved.
//

#import "KoaMentionControlItemCell.h"

@implementation KoaMentionControlItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)applyFont
{
    [self.value setFont:[UIFont fontWithName:@"DroidSans" size:13]];
    [self.description setFont:[UIFont fontWithName:@"DroidSans" size:13]];
}

- (void)applyFontBold
{
    [self.value setFont:[UIFont fontWithName:@"DroidSans-Bold" size:13]];
    [self.description setFont:[UIFont fontWithName:@"DroidSans-Bold" size:13]];
}

@end
