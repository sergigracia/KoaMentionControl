//
//  KoaMentionControlItemCell.h
//  KoaMentionControl
//
//  Created by Sergi Gracia on 21/03/13.
//  Copyright (c) 2013 Sergi Gracia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KoaMentionControlItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *value;
@property (nonatomic, weak) IBOutlet UILabel *description;
@property (nonatomic, weak) IBOutlet UIImageView *image;

@property (nonatomic, weak) NSString *imageUrl;

- (void)applyFont;
- (void)applyFontBold;

@end
