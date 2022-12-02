//
//  BJLTextField.h
//  M9Dev
//
//  Created by MingLQ on 2016-08-22.
//  Copyright (c) 2016 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLTextField: UITextField

// textField.textInsets = textField.editingInsets = textInsets;
@property (nonatomic) UIEdgeInsets borderInsets, textInsets, placeholderInsets, editingInsets;
@property (nonatomic) UIEdgeInsets clearButtonInsets, leftViewInsets, rightViewInsets;

@end

NS_ASSUME_NONNULL_END
