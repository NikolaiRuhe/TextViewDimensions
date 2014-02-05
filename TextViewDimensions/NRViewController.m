//
//  NRViewController.m
//  TextViewDimensions
//
//  Created by Nikolai Ruhe on 05.02.14.
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#import "NRViewController.h"
#import "NRTextViewDimensions.h"

@interface NRViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation NRViewController
{
	NRTextViewDimensions *_dimensions;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

	self.textView.bounds = (CGRect){.size={61, 200}};
	self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	self.textView.backgroundColor = [UIColor yellowColor];
	self.textView.opaque = NO;
	self.textView.scrollEnabled = NO;
	self.textView.textContainerInset = UIEdgeInsetsZero;
	self.textView.textContainer.lineFragmentPadding = 0;
	self.textView.textContainer.maximumNumberOfLines = 0;
	self.textView.layoutManager.usesFontLeading = NO;
	self.textView.text = @"Band-Aid Ripping Off Skin";

	_dimensions = [NRTextViewDimensions new];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)test:(id)sender
{
	[_dimensions testDimensions];
}

@end
