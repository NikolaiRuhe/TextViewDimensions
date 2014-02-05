//
//  NRTextViewDimensions.m
//  TextViewDimensions
//
//  Created by Nikolai Ruhe on 05.02.14.
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#import "NRTextViewDimensions.h"

@implementation NRTextViewDimensions

+ (NSArray *)testStrings
{
	static NSMutableArray *testStrings = nil;
	if (testStrings != nil)
		return testStrings;

	testStrings = [NSMutableArray new];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"DonMartin" ofType:@"plist"];

	for (NSDictionary *quote in [NSDictionary dictionaryWithContentsOfFile:path][@"quotes"]) {
		[testStrings addObject:quote[@"word"]];
		[testStrings addObject:quote[@"soundOf"]];
		[testStrings addObject:quote[@"source"]];
	}

	return testStrings;
}

- (void)testDimensions
{
	[self testProblematicCases];

	UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	NSArray *testStrings = [[self class] testStrings];

	for (NSUInteger i = 1; i <= 100; i += 1) {
		NSUInteger mismatchCount = [self testDimensionsWithWidth:i
															font:font
													 testStrings:testStrings
												   testTextViews:YES
													  testLabels:YES];
		NSLog(@"mismatch count for width: %d pt: %@ of %@", i, @(mismatchCount), @([[[self class] testStrings] count]));
	}
}

- (void)testProblematicCases
{
	[self testDimensionsWithWidth:175
							 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
					  testStrings:@[@"SPLISHIDY-SPLASH- SPLADISH-SPLADISH ..... SPLISHIDY-SPLASHIDY- SPLAPIDY-SPLIP ..."]
					testTextViews:YES
					   testLabels:YES];
	[self testDimensionsWithWidth:133
							 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
					  testStrings:@[@"Coroner Opening , Then Closing Cold Storage Cabinets Where Deceased Are Kept"]
					testTextViews:YES
					   testLabels:YES];
	[self testDimensionsWithWidth:61
							 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
					  testStrings:@[@"Band-Aid Ripping Off Skin"]
					testTextViews:YES
					   testLabels:YES];
	[self testDimensionsWithWidth:27
							 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
					  testStrings:@[@"ZIP"]
					testTextViews:YES
					   testLabels:YES];
	[self testDimensionsWithWidth:31
							 font:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
					  testStrings:@[@"Bell"]
					testTextViews:YES
					   testLabels:YES];
}

static void printLayout(NSLayoutManager *layoutManager, CGFloat width, NSString *path)
{
	__block int i = 0;
	[layoutManager enumerateLineFragmentsForGlyphRange:(NSRange){0, layoutManager.numberOfGlyphs}
											usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
												NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
												NSLog(@"%d [%ld] '%@'", i++, (long)glyphRange.length, [[layoutManager.textStorage string] substringWithRange:characterRange]);
											}];
	UIGraphicsBeginImageContextWithOptions((CGSize){width, 500}, YES, 2);
	[[UIColor whiteColor] set];
	UIRectFill((CGRect){.size={width, 500}});
	[layoutManager drawGlyphsForGlyphRange:(NSRange){0, layoutManager.numberOfGlyphs} atPoint:(CGPoint){0, 250}];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
	UIGraphicsEndImageContext();
}

- (NSUInteger)testDimensionsWithWidth:(CGFloat)width font:(UIFont *)font testStrings:(NSArray *)testStrings testTextViews:(BOOL)testTextViews testLabels:(BOOL)testLabels
{
	NSUInteger mismatchCount = 0;
	BOOL usesFontLeadingForTextView = YES;

	@autoreleasepool {

		UITextView *textView = [[UITextView alloc] initWithFrame:(CGRect){.size = { .width = width, .height = 1000 }}];
		textView.font = font;
		textView.backgroundColor = nil;
		textView.opaque = NO;
		textView.scrollEnabled = NO;
		textView.textContainerInset = UIEdgeInsetsZero;
		textView.textContainer.lineFragmentPadding = 0;
		textView.textContainer.maximumNumberOfLines = 0;
		textView.layoutManager.usesFontLeading = usesFontLeadingForTextView;

		UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){.size = { .width = width, .height = 1000 }}];
		label.font = font;
		label.backgroundColor = nil;
		label.opaque = NO;
		label.numberOfLines = 0;

		NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
		layoutManager.usesFontLeading = usesFontLeadingForTextView;
		NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[NSAttributedString new]];
		[textStorage addLayoutManager:layoutManager];
		NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:(CGSize){width, CGFLOAT_MAX}];
		textContainer.lineFragmentPadding = 0;
		textContainer.maximumNumberOfLines = 0;
		[layoutManager addTextContainer:textContainer];

		// Don't use NSStringDrawingUsesFontLeading, UILabel does not seem to use it
		NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;

		NSDictionary *attributes = @{
			NSFontAttributeName : font,
		};

		for (NSString *testString in testStrings) {

			if (testTextViews) {
				textView.text = testString;
				CGFloat textViewHeight = [textView sizeThatFits:(CGSize){ width, CGFLOAT_MAX }].height;

				[textStorage setAttributedString:[[NSAttributedString alloc] initWithString:testString
																				 attributes:attributes]];
				CGFloat layoutManagerHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
				layoutManagerHeight = ceil(layoutManagerHeight * 2) * 0.5;

				if (textViewHeight != layoutManagerHeight && mismatchCount < 10) {
					mismatchCount += 1;
					NSLog(@"mismatch textViewHeight:%f - layoutManagerHeight:%f in \"%@\"", textViewHeight, layoutManagerHeight, testString);
					NSLog(@"-- layoutManager");
					printLayout(layoutManager, width, @"/Users/nikolai/Desktop/layoutManager.png");

					NSLog(@"-- textView");
					[textView.layoutManager.textContainers[0] setSize:(CGSize){width, CGFLOAT_MAX}];
					printLayout(textView.layoutManager, width, @"/Users/nikolai/Desktop/textView.png");
				}
			}
			if (testLabels) {
				label.text = testString;
				CGFloat labelHeight = [label textRectForBounds:(CGRect){.size={ width, CGFLOAT_MAX }} limitedToNumberOfLines:0].size.height;
				CGFloat stringHeight = [testString boundingRectWithSize:(CGSize){ width, CGFLOAT_MAX }
																options:options
															 attributes:attributes
																context:nil].size.height;
				stringHeight = ceil(stringHeight);
				if (labelHeight != stringHeight && mismatchCount < 10) {
					mismatchCount += 1;
					NSLog(@"mismatch labelHeight:%f - stringHeight:%f in \"%@\"", labelHeight, stringHeight, testString);
				}
			}
		}
	}

	return mismatchCount;
}

@end
