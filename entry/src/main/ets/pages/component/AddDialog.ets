//弹窗


@CustomDialog
export struct addDialog {
  controller: CustomDialogController
  @State eventInput: string = '';
  @State minuteValue: number = 0

  dialogController: CustomDialogController = new CustomDialogController({
    builder: customDialog({
        onValueChange: (value) => {
          this.minuteValue = value
        }
      })
  });

  build() {
    Column() {
      Row() {
        // 取消按钮（左上方）
        Button() {
          Image($r("app.media.close"))
            .width(40)
            .height(40)
            .colorBlend('#ff000000')
            .padding(8)
            .backgroundColor('#ffffffff')
            //.backgroundColor(Color.Transparent)
            //.stateEffect(false) // 禁用状态效果
        }
        .onClick(() => {
          this.controller.close()
        })


        Blank()

        Text("添加待办")

        Blank()

        // 确认按钮（右上方）
        Button() {
          Image($r("app.media.check"))
            .width(40)
            .height(40)
            .colorBlend('#ff000000')
            .padding(8)
            .backgroundColor('#ffffffff')
        }
        .onClick(() => {
          this.controller.close()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Blank()

      // 输入框
      TextInput({ text: this.eventInput, placeholder: '请输入事项名称'})
        .onChange((value: string) => {
          this.eventInput = value
        })
        .margin({top: 20})

      Row() {
        Button('25分钟', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(this.minuteValue === 25 ? '#5B8FF9' : '#F0F0F0')
          .fontColor(this.minuteValue === 25 ? Color.White : '#333')
          .onClick(() => {this.minuteValue == 25})
          .width(90)
          .margin(5)

        Button('15分钟', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(this.minuteValue === 15 ? '#5B8FF9' : '#F0F0F0')
          .fontColor(this.minuteValue === 15 ? Color.White : '#333')
          .onClick(() => {this.minuteValue == 15})
          .width(90)
          .margin(5)

        Button('自定义', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor('#F0F0F0')
          .fontColor('#333')
          .onClick(this.dialogController.open())
          .width(90)
          .margin(5)
      }
    }
    .padding(10)  // 添加一些内边距
  }
}

@CustomDialog
@Component
export struct customDialog{
  controller: CustomDialogController
  @State number: number = 0
  onValueChange: (value: number) => void = () => {};  // 值变更回调
  build() {
    Column() {
  TextInput({ text: this.number.toString(), placeholder: '自定义分钟'})
    .onChange((value: string) => {
      this.number = parseInt(value) // 将输入的字符串转换为数字类型
    })
      Button() {
        Image($r("app.media.check"))
          .width(40)
          .height(40)
          .colorBlend('#ff000000')
          .padding(8)
          .backgroundColor('#ffffffff')
      }
      .onClick(() => {
        this.controller.close()
      })
}
  .alignItems(HorizontalAlign.Center)}}