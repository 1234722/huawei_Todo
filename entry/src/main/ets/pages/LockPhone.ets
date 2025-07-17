@Entry
@Component
struct TomatoTimer {
  @State currentTime: string = this.getFormattedTime()
  @State focusMinutes: number = 25
  @State remainingSeconds: number = 25 * 60
  @State isRunning: boolean = false
  @State timerId: number = -1
  @State showCompletion: boolean = false
  @State ringColor: Color = Color.Blue
  private lastTickTime: number = 0
  private timeUpdateId: number = -1
  @State isLocked: boolean = true // 控制拦截开关

  onBackPress(): boolean {
    if (this.isLocked) {

      return true // 拦截返回键
    }
    return false // 放行返回键
  }

  get progressValue(): number {
    return 1 - (this.remainingSeconds / (this.focusMinutes * 60))
  }

  // 获取格式化时间
  getFormattedTime(): string {
    const now = new Date()
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`
  }

  // 更新当前时间
  updateTime() {
    this.currentTime = this.getFormattedTime()
  }

  // 开始/暂停计时器
  toggleTimer() {
    if (this.isRunning) {
      // 暂停计时器
      if (this.timerId !== -1) {
        clearInterval(this.timerId)
        this.timerId = -1
      }
      this.isRunning = false
    } else {
      // 开始计时器
      if (this.showCompletion) {
        this.showCompletion = false
        this.remainingSeconds = this.focusMinutes * 60
      }

      this.isRunning = true
      this.lastTickTime = new Date().getTime()
      this.timerId = setInterval(() => {
        const now = new Date().getTime()
        const elapsed = this.lastTickTime > 0 ? Math.floor((now - this.lastTickTime)/1000) : 1
        this.remainingSeconds = Math.max(0, this.remainingSeconds - elapsed)
        this.lastTickTime = now

        // 根据剩余时间改变进度条颜色
        if (this.remainingSeconds < this.focusMinutes * 60 * 0.25) {
          this.ringColor = Color.Red
        } else if (this.remainingSeconds < this.focusMinutes * 60 * 0.5) {
          this.ringColor = Color.Orange
        }

        if (this.remainingSeconds <= 0) {
          clearInterval(this.timerId)
          this.timerId = -1
          this.isRunning = false
          this.showCompletion = true
          this.ringColor = Color.Green
        }
      }, 1000)
    }
  }

  // 重置计时器
  resetTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    this.isRunning = false
    this.showCompletion = false
    this.remainingSeconds = this.focusMinutes * 60
    this.ringColor = Color.Blue
  }

  // 设置专注时间
  setFocusTime(minutes: number) {
    this.focusMinutes = minutes
    this.resetTimer()
  }

  // 格式化倒计时显示
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  aboutToAppear() {
    this.timeUpdateId = setInterval(() => {
      this.updateTime()
    }, 1000)
  }

  aboutToDisappear() {
    if (this.timerId !== -1) clearInterval(this.timerId)
    if (this.timeUpdateId !== -1) clearInterval(this.timeUpdateId)
  }

  build() {
    Column() {
      // 顶部当前时间显示

      Button(this.isLocked ? "退出深度专注模式" : "进入深度专注模式")
        .onClick(() => this.isLocked = !this.isLocked)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 0, bottom: 30 })
        .fontColor("#ff030101")
      // 番茄钟卡片
      Stack() {
        // 1. 背景图片层

        Column() {
          // 留空给进度条
        }
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.test'), ImageRepeat.NoRepeat)
        .backgroundColor('#fffffdfd')
        .borderRadius(20)
        .padding(20)
        .shadow({ radius: 10, color: Color.Gray, offsetX: 0, offsetY: 5 })

        // 进度条
        Progress({
          value: this.progressValue,
          style: ProgressStyle.Ring
        })
          .width(200)
          .height(200)
          .color(this.ringColor)
          .animation({ duration: 300, curve: "easeOut" })

        // 倒计时显示
        Text(this.formatTime(this.remainingSeconds))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333")
          .margin({ top: 20 })
      }
      .width('80%')
      .height(300)
      .margin({ bottom: 30 })

      // 完成提示
      if (this.showCompletion) {
        Text('时间到，可以适当休息')
          .fontSize(20)
          .fontColor(Color.Green)
          .margin({ bottom: 20 })
          .opacity(0.9)
      }

      // 时间设置按钮
      Row() {
        Button('25分钟', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(this.focusMinutes === 25 ? '#5B8FF9' : '#F0F0F0')
          .fontColor(this.focusMinutes === 25 ? Color.White : '#333')
          .onClick(() => this.setFocusTime(25))
          .width(90)
          .margin(5)

        Button('15分钟', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(this.focusMinutes === 15 ? '#5B8FF9' : '#F0F0F0')
          .fontColor(this.focusMinutes === 15 ? Color.White : '#333')
          .onClick(() => this.setFocusTime(15))
          .width(90)
          .margin(5)

        Button('5分钟', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(this.focusMinutes === 5 ? '#5B8FF9' : '#F0F0F0')
          .fontColor(this.focusMinutes === 5 ? Color.White : '#333')
          .onClick(() => this.setFocusTime(5))
          .width(90)
          .margin(5)
      }
      .margin({ bottom: 20 })

      // 操作按钮
      Row() {
        Button(this.isRunning ? '暂停' : '开始', { type: ButtonType.Capsule })
          .backgroundColor(this.isRunning ? '#F67280' : '#34BFA3')
          .fontColor(Color.White)
          .width(120)
          .height(40)
          .onClick(() => this.toggleTimer())
          .margin({ right: 15 })

        Button('重置', { type: ButtonType.Capsule })
          .backgroundColor('#F0F0F0')
          .fontColor('#333')
          .width(120)
          .height(40)
          .onClick(() => this.resetTimer())
      }
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F5F7FA')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}