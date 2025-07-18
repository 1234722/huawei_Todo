//弹窗


@CustomDialog
@Component
export struct addDialog {
  controller: CustomDialogController
  @State eventInput: string = '';
  @State minuteValue: number = 0
  @State hour: string = ''
  @State minute: string = ''
  @State hourError: string = ''
  @State minuteError: string = ''

  // dialog2Controller: CustomDialogController = new CustomDialogController({
  //   builder: customDialog({
  //       onValueChange: (value) => {
  //         this.minuteValue = value
  //       }
  //     })
  // });

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
        Text("开始时间")
          .width(100)
          .height(36)
          .fontColor('#ff000000')
          .textAlign(TextAlign.Start)
          .margin({ left: 16 })

        // 小时和分钟输入框组
        Row() {
          TextInput({ text: this.hour, placeholder: '0~23' })
            .width(80)
            .height(40)
            .type(InputType.Number)
            .maxLength(2)
            .onChange((value: string) => {
              const filtered = value.replace(/[^0-9]/g, '')
              if (filtered !== '') {
                const num = parseInt(filtered)
                if (num < 0 || num > 23) {
                  this.hourError = '请输入0~23的数字'
                  this.hour = filtered.slice(0, -1)
                  return
                }
              }
              this.hour = filtered
              this.hourError = ''
            })

          Text(':')
            .fontWeight(500)
            .padding(8)

          TextInput({ text: this.minute, placeholder: '0~59' })
            .width(80)
            .height(40)
            .type(InputType.Number)
            .maxLength(2)
            .onChange((value: string) => {
              const filtered = value.replace(/[^0-9]/g, '')
              if (filtered !== '') {
                const num = parseInt(filtered)
                if (num < 0 || num > 59) {
                  this.minuteError = '请输入0~59的数字'
                  this.minute= filtered.slice(0, -1)
                  return
                }
              }
              this.minute = filtered
              this.minuteError = ''
            })
        }
        .layoutWeight(1)
      }
      .margin({ top: 20 })
      .alignItems(VerticalAlign.Center)

      // 错误提示
      if (this.hourError || this.minuteError) {
        Text(this.hourError || this.minuteError)
          .fontSize(12)
          .fontColor('#FF0000')
          .margin({ top: 4, left: 116 })
      }

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

        TextInput({ text: this.minuteValue.toString(), placeholder: '自定义分钟'})
          .onChange((value: string) => {
            if(Number.isNaN(parseInt(value))){
              this.minuteValue = parseInt(value) // 将输入的字符串转换为数字类型
            }
          })
          .width(90)
          .margin(5)
      }
    }
    .padding(10)  // 添加一些内边距
  }
}

@CustomDialog
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
        this.onValueChange(this.number)
      })
}
  .alignItems(HorizontalAlign.Center)}}