
@Entry
@Component
export struct SliderPage {
  @State sliderValue: number = 25
  @State hourValue: string = ''
  @State minuteValue: string = ''
  @State hourError: string = ''
  @State minuteError: string = ''

  build() {
    Column() {
      // 时间输入行
      Column() {
        Row() {
          Text("开始时间")
            .width(100)
            .height(36)
            .fontColor('#ff000000')
            .textAlign(TextAlign.Start)
            .margin({ left: 16 })

          // 小时和分钟输入框组
          Row() {
            TextInput({ text: this.hourValue, placeholder: '0~23' })
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
                    this.hourValue = filtered.slice(0, -1)
                    return
                  }
                }
                this.hourValue = filtered
                this.hourError = ''
              })

            Text(':')
              .fontWeight(500)
              .padding(8)

            TextInput({ text: this.minuteValue, placeholder: '0~59' })
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
                    this.minuteValue = filtered.slice(0, -1)
                    return
                  }
                }
                this.minuteValue = filtered
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
      }

      // 时长滑块行
      Row() {
        Text("时长(mins)")
          .width(100)
          .height(36)
          .fontColor('#ff000000')
          .margin({ left: 16 })

        Slider({
          value: this.sliderValue,
          min: 0,
          max: 180,
          step: 5,
          style: SliderStyle.OutSet
        })
          .showSteps(false)
          .showTips(true, `${this.sliderValue}`)
          .width('60%')
          .margin({ right: 12 })
          .onChange((value: number) => {
            this.sliderValue = value
          })
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
      .alignItems(VerticalAlign.Center)
    }
  }
}