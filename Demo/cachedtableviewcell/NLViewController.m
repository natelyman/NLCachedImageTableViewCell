//
//  NLViewController.m
//  cachedtableviewcell
//
//  Created by Lyman, Nathan(nlyman) on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"
#import <Twitter/Twitter.h>
#import "NLCachedImageTableViewCell.h"

@interface NLViewController()
- (void) refreshTwitter;
- (BOOL) isEmpty: (id) value;
- (BOOL) isNotEmpty: (id) value;
@property (strong) IBOutlet UITableView *tableView;
@property (strong) NSDictionary *twitterResponses;
@end

@implementation NLViewController

@synthesize tableView = _tableView;
@synthesize twitterResponses = _twitterResponses;


#pragma mark - Private
-(void) refreshTwitter
{
    // Do a simple search, using the Twitter API
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:
                                                         @"http://search.twitter.com/search.json?q=%23iphone&rpp=50&with_twitter_user_id=true&result_type=recent"] 
                                             parameters:nil requestMethod:TWRequestMethodGET];

    // Notice this is a block, it is the handler to process the response
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if ([urlResponse statusCode] == 200) 
         {
             // The response from Twitter is in JSON format
             // Move the response into a dictionary and print
             NSError *error;        
             id jsonObj = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             
             if([jsonObj isKindOfClass:[NSDictionary class]])
             {
                 self.twitterResponses = [NSDictionary dictionaryWithDictionary:(NSDictionary *)jsonObj];
                 [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
             }
             
             [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
         }
         else
             NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
     }];


}

#pragma mark - UITableViewDataSource
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UITableViewCell";
    NLCachedImageTableViewCell *cell = (NLCachedImageTableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(!cell)
    {
        cell = [[NLCachedImageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    
    if([self isNotEmpty:self.twitterResponses])
    {
        NSArray *results = [self.twitterResponses objectForKey:@"results"];
        if([self isNotEmpty:results])
        {
            NSDictionary *result = [results objectAtIndex:indexPath.row];
            if([self isNotEmpty:result])
            {
                NSString *text = [result objectForKey:@"text"];
                if([self isNotEmpty:text])
                {
                    cell.textLabel.text = text;
                }
                
                NSString *fromText = [result objectForKey:@"from_user"];
                if([self isNotEmpty:fromText])
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@",fromText];
                }
                NSString *profileImg = [result objectForKey:@"profile_image_url"];
                if([self isNotEmpty:profileImg])
                {
                    [cell setPlaceholderImage:[UIImage imageNamed:@"User"]];
                    [cell setImageUrlString:profileImg];
                }
            }
        }
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self isNotEmpty:self.twitterResponses])
    {
        NSArray *results = [self.twitterResponses objectForKey:@"results"];
        if([self isNotEmpty:results])
        {
            return [results count];
        }
    }
    return 0;
}


#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self refreshTwitter];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL) isEmpty: (id) value {
    if(value == nil) return YES;
    
    if([value isKindOfClass:[NSNull class]]) return YES;
    
    if([value respondsToSelector:@selector(length)]){
        if([value length] == 0) return YES;
    }
    
    if([value respondsToSelector:@selector(count)]){
        if([value count] == 0) return YES;
    }
    
    if([value isKindOfClass:[NSString class]]){
        if([value isEqualToString:@""]) return YES;
    }
    
    return NO;
}

- (BOOL) isNotEmpty: (id) value {
    return ![self isEmpty:value];
}

@end
