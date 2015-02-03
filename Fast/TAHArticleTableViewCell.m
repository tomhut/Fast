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
    self.titleLabel.preferredMaxLayoutWidth = [self maxTitleWidth];
    self.descriptionLabel.preferredMaxLayoutWidth = [self maxWidth];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.selectedBackgroundView = backgroundView;
}

- (void)setPresentingTV:(UITableView *)presentingTV {
    _presentingTV = presentingTV;
    [self layoutSubviews];
}

- (CGFloat)maxTitleWidth {
    CGFloat appMax = CGRectGetWidth(_presentingTV.frame);
    appMax -= 40;
    return appMax;
}

- (CGFloat)maxWidth {
    CGFloat appMax = CGRectGetWidth(_presentingTV.frame);
    appMax -= 25 + 25;
    return appMax;
}

@end
