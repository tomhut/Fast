//
//  TAHDateHeaderView.m
//  Fast
//
//  Created by Tom Hutchinson on 26/01/2015.
//  Copyright (c) 2015 Tom Hutchinson. All rights reserved.
//

#import "TAHDateHeaderView.h"

@implementation TAHDateHeaderView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _dateLabel.textColor = [UIColor whiteColor];
    [self addSubview:_dateLabel];
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundView = ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.0];
        view;
    });
    
    _dateLabel.frame = CGRectMake(8, 0, self.bounds.size.width, self.bounds.size.height);
    
    
    

}
@end
