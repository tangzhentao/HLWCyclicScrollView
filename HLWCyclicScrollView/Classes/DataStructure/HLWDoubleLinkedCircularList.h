//
//  HLWTwoWayList.h
//  HLWCyclicScrollViewDemo
//
//  Created by tang on 16/9/1.
//  Copyright © 2016年 tang. All rights reserved.
//

// Double-linked circular list 双向循环链表 HLWDoubleLinkedCircularList

#import <Foundation/Foundation.h>
#import "HLWDoubleWayNode.h"

@interface HLWDoubleLinkedCircularList : NSObject

@property (assign, nonatomic) NSUInteger count;
@property (weak, nonatomic) HLWDoubleWayNode *head;

+ (id)doubleLinkedCircularListWithArray:(NSArray *)array;

- (void)addNode:(HLWDoubleWayNode *)node;
- (void)removeNode:(HLWDoubleWayNode *)node;

- (void)print;
- (void)printTwoCircle;


@end
