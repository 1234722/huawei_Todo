import { formatTime, getFormattedTime } from '../../utils/Date'
import { timer } from '../../viewModel/todoUIstate'
import router from '@ohos.router';

@Component
export struct TomatoTimer {
  @ObjectLink timer: timer
  // 把全局属性连进来，方便直接写
  private tickId: number = -1;   // 仅示例，按你自己的实现即可

  @StorageLink('timerRunning') running: boolean = false;

  private ctx = AppStorage.get('Context') as Context;

  toggleTimer() {
    this.timer.toggleTimer();            // 启动 / 暂停真正的计时器
    this.running = this.timer.isRunning; // 同步到全局变量
    console.info('timer.isRunning =', this.timer.isRunning);   // ← 日志 ①
    console.info('global running  =', this.running);           // ← 日志 ②
    this.ctx.eventHub.emit('TIMER_RUNNING', this.running);     // 广播事件
  }


  private onFinish() {
    this.running = false;
    console.info('倒计时结束，running =', this.running);        // 日志 ③
    this.ctx.eventHub.emit('TIMER_RUNNING', false);
    router.back();
  }

  build() {
    Column() {
      // 番茄钟卡片
      Stack() {
        // 1. 背景图片层
        Image($r('app.media.test'))
          .objectFit(ImageFit.Cover)
          .width('100%')
          .height('100%')
          .backgroundColor('#fffffdfd')
          .borderRadius(20)
          .shadow({ radius: 10, color: Color.Gray, offsetX: 0, offsetY: 5 })

        // 倒计时显示
        Text(formatTime(this.timer.remainingSeconds))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333")

        // 进度条
        Progress({
          value: 1 - (this.timer.remainingSeconds / (this.timer.focusMinutes * 60)),
          style: ProgressStyle.Ring
        })
          .width(150)
          .height(150)
          .color(this.timer.ringColor)
          .animation({ duration: 300, curve: "easeOut" })
      }
      .width('80%')
      .height(160)
      // .margin({ bottom: 30 })
      .alignContent(Alignment.Center)

      // 完成提示
      if (this.timer.showCompletion) {
        Text('时间到，可以适当休息')
          .fontSize(20)
          .fontColor(Color.Green)
          .margin({ bottom: 20 })
          .opacity(0.9)
      }

      if(!this.timer.isRunning){
        // 时间设置按钮
        Row() {
          Button('25分钟', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(this.timer.focusMinutes === 25 ? '#5B8FF9' : '#F0F0F0')
            .fontColor(this.timer.focusMinutes === 25 ? Color.White : '#333')
            .onClick(() => this.timer.setFocusTime(25))
            .width(90)
            .margin(5)

          Button('15分钟', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(this.timer.focusMinutes === 15 ? '#5B8FF9' : '#F0F0F0')
            .fontColor(this.timer.focusMinutes === 15 ? Color.White : '#333')
            .onClick(() => this.timer.setFocusTime(15))
            .width(90)
            .margin(5)

          Button('5分钟', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(this.timer.focusMinutes === 5 ? '#5B8FF9' : '#F0F0F0')
            .fontColor(this.timer.focusMinutes === 5 ? Color.White : '#333')
            .onClick(() => this.timer.setFocusTime(5))
            .width(90)
            .margin(5)
        }
        .margin({ bottom: 5 })

        Button(this.timer.isRunning ? '暂停' : '开始', { type: ButtonType.Capsule })
          .backgroundColor(this.timer.isRunning ? '#F67280' : '#34BFA3')
          .fontColor(Color.White)
          .width(120)
          .height(40)
          .onClick(() => this.toggleTimer())   // ←← 关键：改成 this.toggleTimer()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center)
  }
}