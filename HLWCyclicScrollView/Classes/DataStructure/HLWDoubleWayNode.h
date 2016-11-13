//
//  HLWTwoWayList.h
//  HLWCyclicScrollViewDemo
//
//  Created by tang on 16/9/1.
//  Copyright © 2016年 tang. All rights reserved.
//

// double way node 双向节点 HLWDoubleWayNode

#import <Foundation/Foundation.h>

@interface HLWDoubleWayNode : NSObject

@property (weak, nonatomic) id previous;
@property (weak, nonatomic) id next;

@property (strong, nonatomic) id data;
@property (assign, nonatomic) NSUInteger index;

+ (id)doubleWayNodeWithData:(id)data;
+ (id)doubleWayNodeWithData:(id)data index:(NSUInteger)index;

@end
