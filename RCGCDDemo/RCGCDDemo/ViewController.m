//
//  ViewController.m
//  RCGCDDemo
//
//  Created by RongCheng on 2019/3/14.
//  Copyright © 2019年 RongCheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self groupTest2];
}
- (void)groupTest2{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"---satrt----");
    
    //后面的异步任务会被纳入到队列组的监听范围
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
        //离开群组
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
        dispatch_group_leave(group);
    });
    
    //拦截通知,当队列组中所有的任务都执行完毕的时候回进入到下面的方法
//    dispatch_group_notify(group, queue, ^{
//        NSLog(@"-------come,baby");
//    });
    
    // 阻塞的 直到队列组中所有的任务都执行完毕之后才能执行
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"---end----");
}

- (void)groupTest{
    // 1.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 2.创建队列组
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"---satrt----");
    // 3. 添加任务，并监听任务的执行情况,通知group
    dispatch_group_async(group, queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    //拦截通知,当队列组中所有的任务都执行完毕的时候回进入到下面的方法
    dispatch_group_notify(group, queue, ^{
        NSLog(@"-------come,baby");
    });
    NSLog(@"---end----");
}

- (void)applyTest{
    // 开子线程和主线程一起完成遍历任务,任务的执行时并发的
    /*
     参数1: 遍历的次数
     参数2: 队列(并发队列)
     参数3: index 索引
     */
    dispatch_apply(5, dispatch_get_global_queue(0, 0), ^(size_t index) {
        //添加耗时操作，效果更明显
        for(NSInteger i=0;i<100000;i++){
            
        }
        NSLog(@"%zd---%@",index,[NSThread currentThread]);
    });
}

- (void)barrierSync{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"---satrt----");
    dispatch_async(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_barrier_sync(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"4----%@",[NSThread currentThread]);
    });
    NSLog(@"---end----");
}

- (void)barrierAsync{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"---satrt----");
    dispatch_async(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"4----%@",[NSThread currentThread]);
    });
    NSLog(@"---end----");
}

// 延迟函数
- (void)afterDelay{
    //1. 延迟执行的第一种方法
    //[self performSelector:@selector(task) withObject:nil afterDelay:1.0];
    
    //2.延迟执行的第二种方法
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(task) userInfo:nil repeats:YES];
   
    //3.GCD
    /* 参数1: DISPATCH_TIME_NOW 从现在开始计算时间
     * 参数2: 延迟的时间 1.0 GCD时间单位:纳秒
     * 参数3: 队列
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
        //
    });
}

- (void)laodImg{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 下载图片操作
        dispatch_sync(dispatch_get_main_queue(), ^{
            // 显示图片
        });
    });
}

//异步函数+并发队列
- (void)asyncConcurrent{
    // 1.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    NSLog(@"---satrt----");
    // 2.添加任务
    dispatch_async(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    NSLog(@"---end----");
}
// 异步函数+串行队列
- (void)asyncSerial{
    //1.创建队列
    dispatch_queue_t queue = dispatch_queue_create(NULL,  DISPATCH_QUEUE_SERIAL);
    NSLog(@"---satrt----");
    dispatch_async(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    NSLog(@"---end----");
}
// 同步函数+并发队列
-(void)syncConcurrent{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"---start---");
    dispatch_sync(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    NSLog(@"---end----");
}
//同步函数+串行队列
-(void)syncSerial{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    NSLog(@"---start---");
    dispatch_sync(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    NSLog(@"---end----");
}
//异步函数+主队列
-(void)asyncMain{
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSLog(@"---start---");
    dispatch_async(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    NSLog(@"---end----");
}
//同步函数+主队列:死锁
//注意:如果该方法在子线程中执行,那么所有的任务在主线程中执行,
-(void)syncMain{
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSLog(@"start----");
    dispatch_sync(queue, ^{
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"3----%@",[NSThread currentThread]);
    });
    NSLog(@"end---");
}


/*
 有四个优先级
 #define DISPATCH_QUEUE_PRIORITY_HIGH 2
 #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
 #define DISPATCH_QUEUE_PRIORITY_LOW (-2)
 #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
 
 
 // 参数1： 队列的优先级 dispatch_queue_priority_t
 // 参数2： unsigned long flags ，此参数暂时无用，用0即可
 dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
 */

/*
 // 参数1：队列名称，注意传c字符 如："RC"
 // 参数2：队列的类型  DISPATCH_QUEUE_CONCURRENT：并发 ,SERIAL：串行
dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
 */

@end
