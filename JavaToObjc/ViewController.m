//
//  ViewController.m
//  JavaToObjc
//
//  Created by Kyo on 10/12/16.
//  Copyright © 2016 Kyo. All rights reserved.
//

#import "ViewController.h"

static NSString *const kRegexModifierCharacter = @"(private|public)(\\sstatic\\sfinal){0,1}";    /**< java属性修饰符 */

typedef enum : NSInteger {
    JavaValueTypeByte = 0,
    JavaValueTypeShort = 1,
    JavaValueTypeInt = 2,
    JavaValueTypeLong = 3,
    JavaValueTypeFloat = 4,
    JavaValueTypeDouble = 5,
    JavaValueTypeboolean = 6,
    JavaValueTypeChar = 7,
    JavaValueTypeString = 8,
    JavaValueTypeInteger = 9,
    JavaValueTypeList = 10,
    JavaValueTypeDate = 11,
    JavaValueTypeBigDecimal = 12,
} JavaValueType;

@interface ViewController()

@property (unsafe_unretained) IBOutlet NSTextView *txtvJava;
@property (unsafe_unretained) IBOutlet NSTextView *txtvObjc;
@property (weak) IBOutlet NSButton *btnConver;

- (NSString *)converToObjc:(NSString *)javaCode;    /**< 转换成objc代码 */
- (NSString *)clearUnUseChar:(NSString *)javaCode;  /**< 清除无用的字符 */
- (NSString *)converModelToObjcCode:(NSString *)javacode;   /**< 转换java的model属性为objc代码 */
- (NSString *)converTypeToObjcCode:(NSString *)javaCode withType:(JavaValueType)type;   /**< 转换指定类型的java代码为objc代码 */
- (NSString *)strJavaValueType:(JavaValueType)type; /**< 获取Java单位 */
- (NSString *)strObjcValueType:(JavaValueType)type; /**< 获取Objc单位 */

@end

@implementation ViewController

#pragma mark --------------------
#pragma mark - CycLife

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark --------------------
#pragma mark - Settings, Gettings

#pragma mark --------------------
#pragma mark - Events

- (IBAction)btnConverTouchIn:(id)sender {
    NSString *javaCode = self.txtvJava.string;
    self.txtvObjc.string = [self converToObjc:javaCode];
}

#pragma mark --------------------
#pragma mark - Methods

/**< 转换成objc代码 */
- (NSString *)converToObjc:(NSString *)javaCode {
    NSString *objcCode = [self clearUnUseChar:javaCode];
    for (NSInteger i = 0; i <= 12; i++) {
        objcCode = [self converTypeToObjcCode:objcCode withType:i];
    }
    objcCode = [self converModelToObjcCode:objcCode];
    
    return objcCode;
}

/**< 清除无用的字符 */
- (NSString *)clearUnUseChar:(NSString *)javaCode {
    NSString *objcCode = javaCode;
    objcCode = [objcCode stringByReplacingOccurrencesOfString:@" = .{0,10000};" withString:@";" options:NSRegularExpressionSearch range:NSMakeRange(0, objcCode.length)];  //去除默认赋值
    objcCode = [objcCode stringByReplacingOccurrencesOfString:@"<(.{0,20})> "
                                                   withString:@"<$1Model *> *"
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, [objcCode length])];   //把数组的<xxx> 替换成<xxxModel *> *
    
    return objcCode;
}


/**< 转换指定类型的java代码为objc代码 */
- (NSString *)converTypeToObjcCode:(NSString *)javaCode withType:(JavaValueType)type {
    NSString *objcCode = javaCode;
    NSString *javaType = [self strJavaValueType:type];
    NSString *capitalizedJavaType = [NSString stringWithFormat:@"%@%@",[[javaType substringWithRange:NSMakeRange(0, 1)] uppercaseString], [javaType substringFromIndex:1]];
    NSString *objcType = [self strObjcValueType:type];
    
    objcCode = [objcCode stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\\s%@",kRegexModifierCharacter, javaType]
                                                   withString:[NSString stringWithFormat:@"%@", objcType]
                                                      options:NSRegularExpressionSearch range:NSMakeRange(0, objcCode.length)];
    objcCode = [objcCode stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\\s%@",kRegexModifierCharacter, capitalizedJavaType]
                                                   withString:[NSString stringWithFormat:@"%@", objcType]
                                                      options:NSRegularExpressionSearch range:NSMakeRange(0, objcCode.length)];

    return objcCode;
}

/**< 转换java的model属性为objc代码 */
- (NSString *)converModelToObjcCode:(NSString *)javacode {
    NSString *objcCode = javacode;
    objcCode = [objcCode stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\\s{1,5}(\\S{1,20})\\s{1,5}(\\S{1,20};)", kRegexModifierCharacter]
                                                   withString:@"@property (strong, nonatomic) $3Model *$4"
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, [objcCode length])];   //java的model属性转换为objc的model属性
    return objcCode;
}

/**< 获取Java单位 */
- (NSString *)strJavaValueType:(JavaValueType)type {
    NSDictionary *dictType = @{
                               @(0): @"byte\\s",
                               @(1): @"short\\s",
                               @(2): @"int\\s",
                               @(3): @"long\\s",
                               @(4): @"float\\s",
                               @(5): @"double\\s",
                               @(6): @"boolean\\s",
                               @(7): @"char\\s",
                               @(8): @"string\\s",
                               @(9): @"integer\\s",
                               @(10): @"list",
                               @(11): @"date\\s",
                               @(12): @"bigDecimal\\s",
                               @(13): @"周岁",
                               @(14): @"岁" //(实现是:岁（起保日）)
                               };
    return dictType[@(type)] ? : @"";
}

/**< 获取Objc单位 */
- (NSString *)strObjcValueType:(JavaValueType)type {
    NSDictionary *dictType = @{
                               @(0): @"@property (assign, nonatomic) NSInteger ",
                               @(1): @"@property (assign, nonatomic) CGFloat ",
                               @(2): @"@property (assign, nonatomic) NSInteger ",
                               @(3): @"@property (assign, nonatomic) NSInteger ",
                               @(4): @"@property (assign, nonatomic) CGFloat ",
                               @(5): @"@property (assign, nonatomic) CGFloat ",
                               @(6): @"@property (assign, nonatomic) BOOL ",
                               @(7): @"@property (copy, nonatomic) NSString *",
                               @(8): @"@property (copy, nonatomic) NSString *",
                               @(9): @"@property (assign, nonatomic) NSInteger ",
                               @(10): @"@property (strong, nonatomic) NSArray",
                               @(11): @"@property (copy, nonatomic) NSString *",
                               @(12): @"@property (strong, nonatomic) NSDecimalNumber *",
                               @(13): @"周岁",
                               @(14): @"岁" //(实现是:岁（起保日）)
                               };
    return dictType[@(type)] ? : @"";
}


#pragma mark --------------------
#pragma mark - Delegate

#pragma mark --------------------
#pragma mark - NSNotification

#pragma mark --------------------
#pragma mark - KVO/KVC


@end
