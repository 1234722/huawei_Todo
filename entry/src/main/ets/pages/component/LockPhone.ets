import { formatTime, getFormattedTime } from '../../utils/DateTimeUtils'
import { todoUIState } from '../../viewModel/todoUIstate'
import { addDialog, customDialog } from './AddDialog'

@Component
export struct TomatoTimer {
  @Link viewModel: todoUIState

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
        Text(formatTime(this.viewModel.showSeconds))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333")

        // 进度条
        Progress({
          value: 100 - (this.viewModel.showSeconds / (this.viewModel.focusMinutes * 60)) * 100,
          style: ProgressStyle.Ring
        })
          .width(150)
          .height(150)
          .color(this.viewModel.ringColor)
          .animation({ duration: 300, curve: "easeOut" })
      }
      .width('80%')
      .height(160)
      // .margin({ bottom: 30 })
      .alignContent(Alignment.Center)

      if(!this.viewModel.isRunning){
        // 时间设置按钮
        Row() {
          Button('25分钟', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(this.viewModel.focusMinutes === 25 ? '#5B8FF9' : '#F0F0F0')
            .fontColor(this.viewModel.focusMinutes === 25 ? Color.White : '#333')
            .onClick(() => this.viewModel.setFocusTime(25))
            .width(90)
            .margin(5)

          Button('15分钟', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(this.viewModel.focusMinutes === 15 ? '#5B8FF9' : '#F0F0F0')
            .fontColor(this.viewModel.focusMinutes === 15 ? Color.White : '#333')
            .onClick(() => this.viewModel.setFocusTime(15))
            .width(90)
            .margin(5)

          TextInput({ text: this.viewModel.focusMinutes.toString(), placeholder: '自定义分钟'})
            .onChange((value: string) => {
              if(Number.isNaN(parseInt(value))){
                this.viewModel.focusMinutes = parseInt(value) // 将输入的字符串转换为数字类型
              }
            })
            .width(90)
            .margin(5)
        }
        .margin({ bottom: 5 })

        Button(this.viewModel.isRunning ? '暂停' : '开始', { type: ButtonType.Capsule })
          .backgroundColor(this.viewModel.isRunning ? '#F67280' : '#34BFA3')
          .fontColor(Color.White)
          .width(120)
          .height(40)
          .onClick(() => {this.viewModel.startTimer()})
      }
    }
    .width('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center)
  }
}