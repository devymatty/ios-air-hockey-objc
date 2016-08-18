//
//  Paddle.h
//  AirHockey
//
//  Created by Mikhail on 18.08.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Paddle : NSObject {
    UIView *view; // вид клюшки с текущей позицией
    CGRect boundary; // граница
    CGPoint pos; // позиция, в которую передвинеться клюшка
    float maxSpeed; // максимальная скорость
    float speed; // актуальная скорость
    UITouch *touch; // касание присвоенное данной клюшке
}

//@property (assign) UITouch *touch;
@property (readonly) float speed;
@property (assign) float maxSpeed;

// инициализируем объект
- (instancetype)initWithView:(UIView *)paddle boundary:(CGRect)rect maxSpeed:(float)max;

// сбрасываем позицию до середины границы
- (void)reset;

// указываем, куда должна попасть шайба
- (void)move:(CGPoint)pt;

// центральная точка клюшки
- (CGPoint)center;

// проверяем, пересекается ли клюшка с прямоугольником
- (BOOL)intersects:(CGRect)rect;

// получаем расстояние между актуальной позицией клюшки и точкой
- (float)distance:(CGPoint)pt;

// анимируем вид шайбы - она летит к указанной точке, не превышая максимальной скорости
- (void)animate;

@end
