//
//  ViewController.m
//  Paddies
//
//  Created by Mikhail on 27.07.16.
//  Copyright © 2016 iDevelopment Mikey's. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Paddle.h"
#import "Puck.h"
#import "AppDelegate.h"

#define MAX_SCORE 3
#define MAX_SPEED 15

typedef enum {
    AI_START = 0,
    AI_WAIT,
    AI_BORED,
    AI_DEFENSE,
    AI_OFFENSE,
    AI_OFFENSE2
} AIState;

@interface ViewController () {

    // код вспомогательных контроллеров клюшек
    Paddle *paddle1;
    Paddle *paddle2;
    Puck *puck;
    
    NSTimer *timer;
    
    UIAlertController *alertCntrllr;
    
    SystemSoundID sounds[3];
    
    CGRect gPlayerBox[2];
    CGRect gPuckBox;
    CGRect gGoalBox[2];
    
    AIState state;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewPuck;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPaddle1;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPaddle2;
@property (weak, nonatomic) IBOutlet UILabel *viewScore1;
@property (weak, nonatomic) IBOutlet UILabel *viewScore2;

- (void)resume;
- (void)pause;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSounds];
    
    gPlayerBox[0] = CGRectMake(40, 40, self.view.bounds.size.width-80, self.view.bounds.size.height/2-40-32);
    gPlayerBox[1] = CGRectMake(40, self.view.bounds.size.height/2 + 32, self.view.bounds.size.width-80, self.view.bounds.size.height/2-40-32);
    
//    // отладочный код для отображения рамки, в которой может действовать игрок
//    for (int i = 0; i < 2; i++) {
//        
//        UIView *view;
//        if (i==0) {
//            view = [[UIView alloc]initWithFrame:gPlayerBox[0]];
//        } else {
//            view = [[UIView alloc]initWithFrame:gPlayerBox[1]];
//        }
//        view.backgroundColor = [UIColor yellowColor];
//        view.alpha = 0.25;
//        [self.view addSubview:view];
//    }
    
    // создаем вспомогательные контроллеры клюшек
    paddle1 = [[Paddle alloc]initWithView:_imgViewPaddle1
                                 boundary:gPlayerBox[0]
                                 maxSpeed:MAX_SPEED];
    paddle2 = [[Paddle alloc]initWithView:_imgViewPaddle2
                                 boundary:gPlayerBox[1]
                                 maxSpeed:MAX_SPEED];
    
    gPuckBox = CGRectMake(28, 28, self.view.bounds.size.width - 56, self.view.bounds.size.height - 56);
    
    gGoalBox[0] = CGRectMake(100, -20, self.view.bounds.size.width - 200, 49); // рамка, дающая очко первому игроку
    gGoalBox[1] = CGRectMake(102, self.view.bounds.size.height - 29, self.view.bounds.size.width - 200, 49); // рамка, дающая очко второму игроку
    
//    // отладочный код для отображения ворот
//    for (int i = 0; i < 2;  i++) {
//        UIView *view = [[UIView alloc] initWithFrame:gGoalBox[i]];
//        view.backgroundColor = [UIColor greenColor];
//        view.alpha = 0.25;
//        [self.view addSubview:view];
//    }
//    
//    // отладочный код для отображения основного поля для шайбы
//    UIView *view = [[UIView alloc]initWithFrame:gPuckBox];
//    view.backgroundColor = [UIColor cyanColor];
//    view.alpha = 0.25;
//    [self.view addSubview:view];
    
    puck = [[Puck alloc]initWithPuck:_imgViewPuck boundary:gPuckBox goal1:gGoalBox[0] goal2:gGoalBox[1] maxSpeed:MAX_SPEED];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self newGame];
}

#define SOUND_WALL 0
#define SOUND_PADDLE 1
#define SOUND_SCORE 2
// загружаем звуковой эффект в индекс звукового массива
- (void)loadSound:(NSString *)name slot:(int)slot {
    if (sounds[slot] != 0) {
        return;
    }
    
    // создаем имя пути к звуковому файлу
    NSString *sndPath = [[NSBundle mainBundle]pathForResource:name ofType:@"wav" inDirectory:@"/"];
    
    // создаем системный ID звука в нашей звуковой ячейке (слоте)
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:sndPath], &sounds[slot]);
}

- (void)initSounds {
    [self loadSound:@"wall" slot:SOUND_WALL];
    [self loadSound:@"paddle" slot:SOUND_PADDLE];
    [self loadSound:@"score" slot:SOUND_SCORE];
}

- (void)playSound:(int)slot {
    AudioServicesPlaySystemSound(sounds[slot]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // перебираем все элементы касания
    for (UITouch *touch in touches) {
        // получаем точку касания в пределах вида
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // если клюшка еще не присвоена конкретному касанию, то определяем, на какую половину экрана приходится касание
        // и в соответствии с этим присваиваем касание соответствующей клюшке
        if (paddle1.touch == nil && touchPoint.y < self.view.bounds.size.height/2 && _computer == 0) {
            touchPoint.y += 48;
            paddle1.touch = touch;
            [paddle1 move:touchPoint];
            
        } else if (paddle2.touch == nil && touchPoint.y >= self.view.bounds.size.height/2) {
            touchPoint.y -= 24;
            paddle2.touch = touch;
            [paddle2 move:touchPoint];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // итерируем через все объекты касания
    for (UITouch *touch in touches) {
        //  получаем точку касания внутри вида
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // если клюшка еще не присвоена конкретному касанию, то определяем, на какую половину экрана приходиться касание
        // и исходя из этого, присваиваем касание соответствующей клюшке
        if (paddle1.touch == touch) {
            touchPoint.y += 48;
            [paddle1 move:touchPoint];
            
        } else if (paddle2.touch == touch) {
            touchPoint.y -= 24;
            [paddle2 move:touchPoint];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // итерируем через все объекты касания
    for (UITouch *touch in touches) {
        if (paddle1.touch == touch) {
            paddle1.touch = nil;
        } else if (paddle2.touch == touch) {
            paddle2.touch = nil;
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


- (void)computerAI {
    if (state == AI_START) {
        if (paddle2.speed > 0 || (arc4random() % 100) == 1) {
            state = AI_WAIT;
        }
        
    } else if (state == AI_WAIT) {
    
        // дожидаемся, пока клюшка остановится
        if (paddle1.speed == 0) {
            
            // фикс исключающий ситуацию в котором компьютер блокирует шайбу в углу
            if ([paddle1 intersects:_imgViewPuck.frame]) {
                // переходим в состоянии бездействия в результате клюшка перемещается в случайную позицию
                state = AI_BORED;
                return;
            }
            
            paddle1.maxSpeed = MAX_SPEED;
            
            // выбираем случайное число в диапазоне между 0 и 9
            int r = arc4random() % 10;
            
            // если выбрано число 1
            // то происходит переход в новое состояние
            if (r == 1) {
                // если шайба находиться на нашей стороне и не движется слишком быстро
                // переходим в нападение
                // если шайба перемещается вверх с достаточной скоростью
                // переходим состояние защиты
                // в ином случае переходим в состояние бездействия
                
                if (puck.center.y <= self.view.bounds.size.height/2 && puck.speed < 1) {
                    state = AI_OFFENSE;
                
                } else if (puck.speed >= 1 && puck.dy < 0) {
                    state = AI_DEFENSE;
                
                } else {
                    state = AI_BORED;
                }
            }
        }
    } else if (state == AI_OFFENSE) {
        // выбираем новую позицию по оси X между -64 и +64 от центра шайбы
        float x = puck.center.x - 64 + (arc4random() % 129);
        float y = puck.center.y - 64 - (arc4random() % 64);
        [paddle1 move:CGPointMake(x, y)];

        state = AI_OFFENSE2;
        
    } else if (state == AI_OFFENSE2) {
        if (paddle1.speed == 0) {
            // бьем
            [paddle1 move:puck.center];
            state = AI_WAIT;
        }
        
    } else if (state == AI_DEFENSE) {
        // выводим в позицию х, занимаемую шайбой,
        // и делим пополам расстояние, между ней и воротами
        [paddle1 move:CGPointMake(puck.center.x, puck.center.y/2)];
        
        if (puck.speed < 1) {
            state = AI_WAIT;
        }
        paddle1.maxSpeed = MAX_SPEED / 3;
        
        // компьютер был в состоянии бездействия, а теперь переводит клюшку в новую позицию
    } else if (state == AI_BORED) {
        if (paddle1.speed == 0) {
            // перемещаем клюшку paddle1 в случайную позицию в пределах поля
            // игрока player1
            float x = gPlayerBox[0].origin.x + arc4random() % (int)gPlayerBox[0].size.width;
            
            float y = gPlayerBox[0].origin.y + arc4random() % (int)gPlayerBox[0].size.height;
            [paddle1 move:CGPointMake(x, y)];
            state = AI_WAIT;
        }
    }
}


- (void)reset {
    // возвращаем компьютерного игрока в состояние ожидания
    state = AI_WAIT;
    // сбрасываем значения клюшек
    [paddle1 reset];
    [paddle2 reset];
    [puck reset];
    
}

- (void)animate {
    // проверяем наличие компьютерного игрока
    if (_computer) {
        [self computerAI];
    }
    
    // перемещаем клюшку
    [paddle1 animate];
    [paddle2 animate];
    
    // обработка соударения клюшек, возвращающих YES при возникновении соударения
    if ([puck handleCollision:paddle1] || [puck handleCollision:paddle2]) {
        // звук удара шайбы
        [self playSound:SOUND_PADDLE];
    }
    
    // анимируем шайбу, возвращая YES, если произошло столкновение со стенкой
    if ([puck animate]) {
        [self playSound:SOUND_WALL];
    }
    
    // проверяем был ли забит гол
    if ([self checkGoal]) {
        [self playSound:SOUND_SCORE];
    }

}

- (void)start {
    if (timer == nil) {
        // создаем анимационный таймер
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                 target:self
                                               selector:@selector(animate)
                                               userInfo:nil
                                                repeats:YES];
    }
    // оображаем мячик
    _imgViewPuck.hidden = NO;
}

- (void)stop {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    
    // скрываем мячик
    _imgViewPuck.hidden = YES;
}

- (BOOL)checkGoal {
    // Проверяем, не вышла ли шайба за границы поля, и если так - сбрасываем игру
    
    if (puck.winner != 0) {
    
        // получаем целочисленное значение из содержимого подписи со счетом
        int s1 = _viewScore1.text.intValue;
        int s2 = _viewScore2.text.intValue;
        
        // даем очко тому игроку,который его заработал
        if (puck.winner == 2) {
            ++s2;
        } else {
            ++s1;
        }
        
        // обновляем подписи со счетом
        _viewScore1.text = [NSString stringWithFormat:@"%u", s1];
        _viewScore2.text = [NSString stringWithFormat:@"%u", s2];
        
        // проверяем, кто победил в раудне
        if ([self gameOver] == 1) {
            // называем победителя
            [self displayMessage:@"Player 1 has won!"];
        } else if ([self gameOver] == 2) {
            // называем победителя
            [self displayMessage:@"Player 2 has won!"];
        } else {
            // сбрасываем прежний раунд и начинам новый
            [self reset];
        }
        
        // возвращаем TRUE, если забит гол
        return YES;
    }
    
    // гол не забит
    return NO;
}

- (void)displayMessage:(NSString *)msg {
    
    // не отображаем более одного сообщения
    if (alertCntrllr) {
        return;
    }

    // останавливаем анимационный таймер
    [self stop];
    
    // создаем и выводим на экран сообщение с предупреждением
    alertCntrllr = [UIAlertController alertControllerWithTitle:@"Game" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // сообщение убрано с экрана поэтому игра сбрасывается и запускается анимация
        alertCntrllr = nil;
        
        if ([self gameOver]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showTitle];
            [self newGame];//
            return;
        }
        
        [self reset];
        [self start];
    }];
    
    [alertCntrllr addAction:okAction];

    [self presentViewController:alertCntrllr animated:YES completion:nil];
}

- (void)newGame {
    [self reset];
    
    // сбрасываем счет
    _viewScore1.text = @"0";
    _viewScore2.text = @"0";
    
    // отображаем сообщение о том, что игра начинается
    [self displayMessage:@"Ready to play?"];
}

- (int)gameOver {
    if (_viewScore1.text.intValue >= MAX_SCORE) {
        return 1;
    }
    if (_viewScore2.text.intValue >= MAX_SCORE) {
        return 2;
    }
    return 0;
}

- (void)pause {
    [self stop];
}

- (void)resume {
    // чтобы продолжить игру, отображаем соответствующее сообщение
    [self displayMessage:@"Game Paused"];
}

@end














