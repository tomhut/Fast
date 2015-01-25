//
//  TAHArticleTableViewCell.m
//  ftapitest
//
//  Created by Tom Hutchinson on 11/01/2015.
//  Copyright (c) 2015 JustYoyo Ltd. All rights reserved.
//

#import "TAHArticleTableViewCell.h"

@implementation TAHArticleTableViewCell

- (void)awakeFromNib {
    self.titleLabel.preferredMaxLayoutWidth = [self maxWidth];
    self.descriptionLabel.preferredMaxLayoutWidth = [self maxWidth];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = [self maxWidth];
//    self.descriptionLabel.preferredMaxLayoutWidth = [self maxWidth];
}



- (CGFloat)maxWidth {
    CGFloat appMax = CGRectGetWidth([UIApplication sharedApplication].keyWindow.frame);
    appMax -= 22 + 22;
    return appMax;
}

@end
