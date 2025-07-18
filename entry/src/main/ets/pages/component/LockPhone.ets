import { formatTime, getFormattedTime } from '../../utils/DateTimeUtils'
import { timer } from '../../viewModel/todoUIstate'
import { addDialog, customDialog } from './AddDialog'

@Component
export struct TomatoTimer {
  @ObjectLink timer: timer

  // dialog3Controller: CustomDialogController = new CustomDialogController({
  //   builder: addDialog()
  // })

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
        Text(formatTime(this.timer.showSeconds))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333")

        // 进度条
        Progress({
          value: 100 - (this.timer.showSeconds / (this.timer.focusMinutes * 60)) * 100,
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

          TextInput({ text: this.timer.focusMinutes.toString(), placeholder: '自定义分钟'})
            .onChange((value: string) => {
              if(Number.isNaN(parseInt(value))){
                this.timer.focusMinutes = parseInt(value) // 将输入的字符串转换为数字类型
              }
            })
            .width(90)
            .margin(5)
        }
        .margin({ bottom: 5 })

        Button(this.timer.isRunning ? '暂停' : '开始', { type: ButtonType.Capsule })
          .backgroundColor(this.timer.isRunning ? '#F67280' : '#34BFA3')
          .fontColor(Color.White)
          .width(120)
          .height(40)
          .onClick(() => {this.timer.startTimer()})
      }
    }
    .width('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center)
  }
}