//
//  NLCachedImageTableViewCell.m
//  Nate Lyman
//
//  Created by Lyman, Nathan(nlyman) on 1/9/12.
//  Copyright (c) 2012 NateLyman.com. All rights reserved.
//

#import "NLCachedImageTableViewCell.h"
#import <CommonCrypto/CommonDigest.h>

@interface NLCachedImageTableViewCell()
- (NSString*) sha1: (NSString *)str;
@end

@implementation NLCachedImageTableViewCell
@synthesize imageUrlString = _imageUrlString;
@synthesize placeholderImage = _placeholderImage;

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

- (void) setImageUrlString:(NSString *)imageUrlString
{
    _imageUrlString = imageUrlString;
    
    NSString *key = [self sha1:imageUrlString];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *fileToSave = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",key]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileToSave];
    
    if (!fileExists)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
        dispatch_async(queue, ^{
            
            NSURL *imageURL=[NSURL URLWithString:imageUrlString];
            
            NSData *imageData=[NSData dataWithContentsOfURL:imageURL];
            
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            NSData *jpegData = UIImageJPEGRepresentation(image,100);
            
            [[NSFileManager defaultManager] createFileAtPath:fileToSave contents:jpegData attributes:nil];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
                [self setNeedsLayout];
            });
        });
        self.imageView.image = self.placeholderImage;
    }else{
        UIImage *image = [UIImage imageWithContentsOfFile:fileToSave];
        if(!image) image = self.placeholderImage;
        
        self.imageView.image = image;
    }

    
}

-(NSString*) sha1: (NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

@end
