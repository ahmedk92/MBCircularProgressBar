//
//  MBCircularProgressBarLayer.m
//  MBCircularProgressBar
//
//  Created by Mati Bot on 7/9/15.
//  Copyright (c) 2015 Mati Bot All rights reserved.
//

@import UIKit;
@import CoreGraphics;

#import "MBCircularProgressBarLayer.h"

@implementation MBCircularProgressBarLayer
@dynamic value;
@dynamic maxValue;
@dynamic borderPadding;
@dynamic valueFontSize;
@dynamic unitString;
@dynamic unitFontSize;
@dynamic progressLineWidth;
@dynamic progressColor;
@dynamic progressStrokeColor;
@dynamic emptyLineWidth;
@dynamic progressAngle;
@dynamic emptyLineColor;
@dynamic emptyLineStrokeColor;
@dynamic emptyCapType;
@dynamic progressCapType;
@dynamic fontColor;
@dynamic progressRotationAngle;
@dynamic progressAppearanceType;
@dynamic decimalPlaces;
@dynamic valueDecimalFontSize;
@dynamic unitFontName;
@dynamic valueFontName;
@dynamic showUnitString;
@dynamic showValueString;
@dynamic textOffset;
@dynamic countdown;
@dynamic lapCircleRadius;
@dynamic lapCircleText;
@dynamic lapCircleFillColor;
@dynamic lapCircleStrokeColor;

#pragma mark - Drawing

//-(void)setValue:(CGFloat)value{
//    [self drawProgressBar:<#(CGSize)#> context:<#(CGContextRef)#>]
//}

- (void) drawInContext:(CGContextRef) context{
    [super drawInContext:context];

    UIGraphicsPushContext(context);
    
    CGRect rect = CGContextGetClipBoundingBox(context);
    rect = CGRectIntegral(CGRectInset(rect, self.borderPadding, self.borderPadding));
    
    [self drawEmptyBar:rect context:context];
    [self drawProgressBar:rect context:context];
  
    if (self.showValueString){
      [self drawText:rect context:context];
    }
    
    UIGraphicsPopContext();
}

- (void)drawEmptyBar:(CGRect)rect context:(CGContextRef)c{
    
    if(self.emptyLineWidth <= 0){
        return;
    }
    
    CGPoint center = {CGRectGetMidX(rect), CGRectGetMidY(rect)};
    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2;
    if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeOverlaysEmptyLine) {
        radius = radius - MAX(self.emptyLineWidth, self.progressLineWidth)/2.f;
    } else if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeAboveEmptyLine) {
        radius = radius - self.progressLineWidth - self.emptyLineWidth/2.f;
    } else {
        radius = radius - self.emptyLineWidth/2.f;
    }
    
    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathAddArc(arc, NULL,
                 center.x, center.y, radius,
                 (self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI,
                 -(self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI,
                 YES);
    

    CGPathRef strokedArc =
    CGPathCreateCopyByStrokingPath(arc, NULL,
                                   self.emptyLineWidth,
                                   (CGLineCap)self.emptyCapType,
                                   kCGLineJoinMiter,
                                   10);
    
    
    CGContextAddPath(c, strokedArc);
    CGContextSetStrokeColorWithColor(c, self.emptyLineStrokeColor.CGColor);
    CGContextSetFillColorWithColor(c, self.emptyLineColor.CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
    
    CGPathRelease(arc);
    CGPathRelease(strokedArc);
}

- (void)drawProgressBar:(CGRect)rect context:(CGContextRef)c{
    if(self.progressLineWidth <= 0){
        return;
    }
    
    CGPoint center = {CGRectGetMidX(rect), CGRectGetMidY(rect)};
    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2;
    if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeOverlaysEmptyLine) {
        radius = radius - MAX(self.emptyLineWidth, self.progressLineWidth)/2.f;
    } else if (self.progressAppearanceType == MBCircularProgressBarAppearanceTypeAboveEmptyLine) {
        radius = radius - self.progressLineWidth/2.f;
    } else {
        radius = radius - self.emptyLineWidth - self.progressLineWidth/2.f;
    }
    
    CGMutablePathRef arc = CGPathCreateMutable();
    CGFloat startAngle = (self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI-(2.f*M_PI)*(self.progressAngle/100.f)*(100.f-100.f*self.value/self.maxValue)/100.f;
    CGFloat endAngle = -(self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI;
    
    CGPathAddArc(arc, NULL,
                 center.x, center.y, radius,
                 startAngle,
                 endAngle,
                 YES);
    
    CGPathRef strokedArc =
    CGPathCreateCopyByStrokingPath(arc, NULL,
                                   self.progressLineWidth,
                                   (CGLineCap)self.progressCapType,
                                   kCGLineJoinMiter,
                                   10);

    
    CGContextAddPath(c, strokedArc);
    CGContextSetFillColorWithColor(c, self.progressColor.CGColor);
    CGContextSetStrokeColorWithColor(c, self.progressStrokeColor.CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
    
    CGPathRelease(arc);
    CGPathRelease(strokedArc);
    
    CGPoint lapPoint = CGPointMake(radius * cos(startAngle) + center.x,  radius * sin(startAngle) + center.y);
    
    [self drawLapCircle:lapPoint context:c];
}

- (void)drawLapCircle:(CGPoint)lapPoint context:(CGContextRef)c {
    CGFloat radius = self.lapCircleRadius;
    if (radius <= 0) return;
    
    CGMutablePathRef lapCircle = CGPathCreateMutable();
    CGPathAddArc(lapCircle, NULL, lapPoint.x, lapPoint.y, radius, 0, 2 * M_PI, YES);
    CGContextAddPath(c, lapCircle);
    CGContextSetFillColorWithColor(c, self.lapCircleFillColor.CGColor);
    CGContextSetStrokeColorWithColor(c, self.lapCircleStrokeColor.CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);
    CGPathRelease(lapCircle);
    
    [self drawLapCircleText:lapPoint radius:radius context:c text:self.lapCircleText ?: @""];

}

- (void)drawLapCircleText:(CGPoint)lapPoint radius:(CGFloat)radius context:(CGContextRef)c text:(NSString*)text {
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentLeft;
    
    CGFloat valueFontSize = radius;
    
    NSDictionary* valueFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: self.valueFontName size:valueFontSize], NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};
    
    NSString *formatString = [NSString stringWithFormat:@"%%.%df", (int)self.decimalPlaces];
    
    
    NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:text
                                                                attributes:valueFontAttributes];
    
    [attributedText drawAtPoint:CGPointApplyAffineTransform(lapPoint, CGAffineTransformMakeTranslation(-attributedText.size.width / 2, - attributedText.size.height / 2))];
}

- (void)drawText:(CGRect)rect context:(CGContextRef)c {
    [self drawText:rect context:c text:nil];
}

- (void)drawText:(CGRect)rect context:(CGContextRef)c text:(NSString*)textToPresent {
  NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
  textStyle.alignment = NSTextAlignmentLeft;
  
  CGFloat valueFontSize = self.valueFontSize == -1 ? CGRectGetHeight(rect)/5 : self.valueFontSize;
  
  NSDictionary* valueFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: self.valueFontName size:valueFontSize], NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};
  
  NSMutableAttributedString *text = [NSMutableAttributedString new];
  
  NSString *formatString = [NSString stringWithFormat:@"%%.%df", (int)self.decimalPlaces];
    
    
    if (textToPresent == nil) {
        if (self.countdown) {
            textToPresent = [NSString stringWithFormat:formatString, (self.maxValue - self.value)];
        } else {
            textToPresent = [NSString stringWithFormat:formatString, self.value];
        }
    }
  NSAttributedString* value = [[NSAttributedString alloc] initWithString:textToPresent
                                                                attributes:valueFontAttributes];
  [text appendAttributedString:value];
  
  // set the decimal font size
  NSUInteger decimalLocation = [text.string rangeOfString:@"."].location;
  if (decimalLocation != NSNotFound){
    NSDictionary* valueDecimalFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: self.valueFontName size:self.valueDecimalFontSize == -1 ? valueFontSize : self.valueDecimalFontSize], NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};
    NSRange decimalRange = NSMakeRange(decimalLocation, text.length - decimalLocation);
    [text setAttributes:valueDecimalFontAttributes range:decimalRange];
  }
  
  // ad the unit only if specified
  if (self.showUnitString) {
    NSDictionary* unitFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: self.unitFontName size:self.unitFontSize == -1 ? CGRectGetHeight(rect)/7 : self.unitFontSize], NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};
    
    NSAttributedString* unit =
    [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.unitString] attributes:unitFontAttributes];
    [text appendAttributedString:unit];
  }
  
  CGSize percentSize = [text size];
  CGPoint textCenter = CGPointMake(
    CGRectGetMidX(rect)-percentSize.width/2 + self.textOffset.x,
    CGRectGetMidY(rect)-percentSize.height/2 + self.textOffset.y
  );
  
  [text drawAtPoint:textCenter];
}

#pragma mark - Override methods to support animations

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"value"] || [key isEqualToString:@"lapCircleRadius"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event{
    if ([self presentationLayer] != nil) {
        if ([event isEqualToString:@"value"]) {  
            id animation = [super actionForKey:@"backgroundColor"];
            
            if (animation == nil || [animation isEqual:[NSNull null]])
            {
                [self setNeedsDisplay];
                return [NSNull null];
            }
            [animation setKeyPath:event];
            [animation setFromValue:[self.presentationLayer valueForKey:@"value"]];
            [animation setToValue:nil];
            return animation;
        }
        if ([event isEqualToString:@"lapCircleRadius"]) {
            id animation = [super actionForKey:@"backgroundColor"];
            
            if (animation == nil || [animation isEqual:[NSNull null]])
            {
                [self setNeedsDisplay];
                return [NSNull null];
            }
            [animation setKeyPath:event];
            [animation setFromValue:[self.presentationLayer valueForKey:@"lapCircleRadius"]];
            [animation setToValue:nil];
            return animation;
        }
    }
    
    return [super actionForKey:event];
}

@end
