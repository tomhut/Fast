//
//  TAHArticleTableViewCell.h
//  ftapitest
//
//  Created by Tom Hutchinson on 11/01/2015.
//  Copyright (c) 2015 JustYoyo Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAHArticleTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) UITableView *presentingTV;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;

@end
