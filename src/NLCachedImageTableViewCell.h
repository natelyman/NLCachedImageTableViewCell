//
//  NLCachedImageTableViewCell.h
//  niners
//
//  Created by Lyman, Nathan(nlyman) on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLCachedImageTableViewCell : UITableViewCell

@property (strong,nonatomic) NSString *imageUrlString;
@property (strong) UIImage *placeholderImage;

@end
